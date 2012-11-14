#!/bin/env ruby

$machine_pool = "./machine_pool"
$preinfo = "./preinfo"

class Machine_info
  def all_ip_info 
    machine_list = {}
    machine_pair = ""
    File.open("#{$machine_pool}").each do |host|
      if host !~ /^\s*$\n/
        host = host.chomp
        ip = `host #{host}|awk '{print $4}'`.chomp
        machine_pair="#{host}:#{ip}"
        ip_seg = `echo #{ip}|cut -d . -f 1-3`.chomp
  
        if machine_list.has_key?("#{ip_seg}")
         machine_list["#{ip_seg}"] << machine_pair  
        else
         machine_list["#{ip_seg}"] ||= []
         machine_list["#{ip_seg}"] << machine_pair
        end  
      end
    end
    return machine_list
  end

  def machine_group(machine_list)
    machine_group = {}
    machine_list = machine_list.sort_by{|k,v| v.size}.reverse
    group_num = machine_list[0][1].size
    1.upto(group_num) do |i|
      machine_group["group#{i}"] ||= []
      machine_list.each do |x|
        unless x[1].empty?
          machine_group["group#{i}"] << x[1].shift
        end
      end
    end
    return machine_group
  end

  def mixed_single_machine(machine_group)
    machine_list ||= []
    machine_group.each do |k,v|
        puts k
      if machine_group[k].size > 1
        machine_list << v
      else
        machine_list = machine_list.flatten
        max = machine_list.size
        puts "#{max}"
        position = rand(max)
        puts "rand #{position}"
        machine_list.insert(position,"#{v[0]}")
      end
    end
    #p machine_list
    return machine_list.flatten
  end

end

$machine_list = Machine_info.new.all_ip_info
machine_group = Machine_info.new.machine_group($machine_list)
machine_list_mixd = Machine_info.new.mixed_single_machine(machine_group)

ret = {}
File.foreach($preinfo) do |line|
  if line !~ /^\s*$\n/
    mod = line.chomp.split[0]
    host_num = line.chomp.split[1].to_i
    puts mod
    puts host_num
    if machine_list_mixd.size >= host_num
      ret["#{mod}"] = machine_list_mixd.shift(host_num)
    else
      puts "ERROR: there is no #{host_num} host for #{mod} ! "
    end
  end
end

output_file = "./allot_machine.output"
File.open("#{output_file}",mode="w") do |fd|
  ret.each do |k,v|
    v.each do |host|
      fd << "#{k} #{host}\n"
    end
  end
end
