allot_machine
=============

尽可能分散网段地分配机器

1、machine_pool是原始机器列表文件，每行一台机器名

2、preinfo文件是各个模块需要的机器数量，每一行的格式为: modulename hostnum ;例如： imas 100

3、allot_machine.output文件是最终的分配结果