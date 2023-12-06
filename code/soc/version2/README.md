## FPGA验证

该版本加入了完整的DMA、SD卡读取控制模块、异步fifo等，将SD卡中数据搬移到相应地址区间，只能通过FPGA来验证SD卡读取是否成功。

该版本通过DMA模块将从SD卡读取的数据写入相应的地址区间中（ITCM、DTCM、SDRAM）。

![image-20231206161605846](/home/wxt/.config/Typora/typora-user-images/image-20231206161605846.png)

<center>图1. SoC架构

SD卡数据读取流程：

1）上电后，处理器执行ROM中固定地址boot程序：初始化中断信号（打开中断使能、清除mcause等），通过外设地址写入DMA控制寄存器，包括读取SD卡起始扇区地址SDStartAddr（地址：0x4000_0020），读取SD卡连续的块数SDCounts（0x4000_0024），写入的AHB存储区间地址DestAddr，开始读取SD卡使能信号DMAEN。当写入完成DMAEN寄存器时，DMA开始读取SD卡数据。

2）DMA检测到DMAEN寄存器被配置后，向SD卡读取控制模块SD_CTRL发送信号，即SDStartAddr、SDCounts、DMAEN内容。SD_CTRL检测到DMAEN信号后，开始从SDStartAddr块（SD卡每块大小为512 bytes）地址处开始读取SD卡数据，SD卡每次读出一个完整数据32 bits，都会存入异步fifo（由于SD读取数据时钟频率要比处理器运行频率低得多，需要通用异步fifo完成数据的跨时钟域传输）。每存入异步fifo一个数据，DMA模块检测异步fifo非空时，在总线准备好（dma_hready）的状态下都会读取异步fifo中数据，写入DestAddr地址处，每次写完地址递增4，等待下次写入。

3）直至读取完成所有SDCounts块数的数据，DMA触发搬移SD数据完成信号，传给处理器核，处理器检测到后触发SD卡数据搬移完成中断（在SD卡数据搬移期间，处理器核一直在检测相关搬移完成标志位，在空转），进入相应中断例程程序。开始下一步相关程序执行。

当SD卡中所有数据搬移完成后，PC寄存器跳转到相应的地址区间（ITCM或者SDRAM）开始执行主程序。

 

 

 