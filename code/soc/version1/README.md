## Modelsim仿真

​	该版本主要是加入boot程序，用于上电后将系统代码从SD卡载入片上存储空间，只有modelsim仿真版本（也可以自行部署到FPGA上验证运行，只需要替换ram ip核和初始化coe文件即可）。为此扩展了AHB总线架构，如下图所示，从端增加了ROM、SDRAM、SD卡模块。其中ROM大小为16kB，用于存放boot程序。SDRAM最大为256MB，为片外存储空间，如果程序大小超过ITCM（64kB），或是有大量图像数据等等，存放在SDRAM中，这样无论取指还是访问数据，IBUS和DBUS都是访问SDRAM区间，每次访存都需要暂停取指，会导致流水线执行效率低。SD卡为二进制文件初始时存入的外设，这里依旧使用cmsdk_fpga_sram来模拟，方便modelsim仿真。并且中间加了个AHB转APB的桥，因为实际过程中SD卡读取频率要比处理器运行频率慢很多，故使用APB总线接口，更低的时钟频率驱动SD模块。AHB转APB桥会做跨异步时钟数据处理。

​	上电后从boot程序执行：boot程序通过load、store指令先将SD卡中文件头数据，即第0块的数据512 Bytes搬移到ITCM中（boot程序默认程序代码从SD卡第0块地址开始存放），计算出整个程序文件大小。如果程序文件大小不超过64kB，则计算出剩余文件量在SD卡中占据了多少块，通过load、store指令全部搬入ITCM中；否则搬入SDRAM中。然后再跳转到ITCM或是SDRAM的程序执行入口start处，开始进入程序代码继续后续执行。

![image-20231206161432835](/home/wxt/.config/Typora/typora-user-images/image-20231206161432835.png)