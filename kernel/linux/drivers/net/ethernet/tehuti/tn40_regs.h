/* SPDX-License-Identifier: GPL-2.0+ */
/* Copyright (c) Tehuti Networks Ltd. */

#ifndef _TN40_REGS_H_
#define _TN40_REGS_H_

/* Register region size */
#define TN40_REGS_SIZE 0x10000

/* Registers from 0x0000-0x00fc were remapped to 0x4000-0x40fc */
#define TN40_REG_TXD_CFG1_0 0x4000
#define TN40_REG_TXD_CFG1_1 0x4004
#define TN40_REG_TXD_CFG1_2 0x4008
#define TN40_REG_TXD_CFG1_3 0x400C

#define TN40_REG_RXF_CFG1_0 0x4010
#define TN40_REG_RXF_CFG1_1 0x4014
#define TN40_REG_RXF_CFG1_2 0x4018
#define TN40_REG_RXF_CFG1_3 0x401C

#define TN40_REG_RXD_CFG1_0 0x4020
#define TN40_REG_RXD_CFG1_1 0x4024
#define TN40_REG_RXD_CFG1_2 0x4028
#define TN40_REG_RXD_CFG1_3 0x402C

#define TN40_REG_TXF_CFG1_0 0x4030
#define TN40_REG_TXF_CFG1_1 0x4034
#define TN40_REG_TXF_CFG1_2 0x4038
#define TN40_REG_TXF_CFG1_3 0x403C

#define TN40_REG_TXD_CFG0_0 0x4040
#define TN40_REG_TXD_CFG0_1 0x4044
#define TN40_REG_TXD_CFG0_2 0x4048
#define TN40_REG_TXD_CFG0_3 0x404C

#define TN40_REG_RXF_CFG0_0 0x4050
#define TN40_REG_RXF_CFG0_1 0x4054
#define TN40_REG_RXF_CFG0_2 0x4058
#define TN40_REG_RXF_CFG0_3 0x405C

#define TN40_REG_RXD_CFG0_0 0x4060
#define TN40_REG_RXD_CFG0_1 0x4064
#define TN40_REG_RXD_CFG0_2 0x4068
#define TN40_REG_RXD_CFG0_3 0x406C

#define TN40_REG_TXF_CFG0_0 0x4070
#define TN40_REG_TXF_CFG0_1 0x4074
#define TN40_REG_TXF_CFG0_2 0x4078
#define TN40_REG_TXF_CFG0_3 0x407C

#define TN40_REG_TXD_WPTR_0 0x4080
#define TN40_REG_TXD_WPTR_1 0x4084
#define TN40_REG_TXD_WPTR_2 0x4088
#define TN40_REG_TXD_WPTR_3 0x408C

#define TN40_REG_RXF_WPTR_0 0x4090
#define TN40_REG_RXF_WPTR_1 0x4094
#define TN40_REG_RXF_WPTR_2 0x4098
#define TN40_REG_RXF_WPTR_3 0x409C

#define TN40_REG_RXD_WPTR_0 0x40A0
#define TN40_REG_RXD_WPTR_1 0x40A4
#define TN40_REG_RXD_WPTR_2 0x40A8
#define TN40_REG_RXD_WPTR_3 0x40AC

#define TN40_REG_TXF_WPTR_0 0x40B0
#define TN40_REG_TXF_WPTR_1 0x40B4
#define TN40_REG_TXF_WPTR_2 0x40B8
#define TN40_REG_TXF_WPTR_3 0x40BC

#define TN40_REG_TXD_RPTR_0 0x40C0
#define TN40_REG_TXD_RPTR_1 0x40C4
#define TN40_REG_TXD_RPTR_2 0x40C8
#define TN40_REG_TXD_RPTR_3 0x40CC

#define TN40_REG_RXF_RPTR_0 0x40D0
#define TN40_REG_RXF_RPTR_1 0x40D4
#define TN40_REG_RXF_RPTR_2 0x40D8
#define TN40_REG_RXF_RPTR_3 0x40DC

#define TN40_REG_RXD_RPTR_0 0x40E0
#define TN40_REG_RXD_RPTR_1 0x40E4
#define TN40_REG_RXD_RPTR_2 0x40E8
#define TN40_REG_RXD_RPTR_3 0x40EC

#define TN40_REG_TXF_RPTR_0 0x40F0
#define TN40_REG_TXF_RPTR_1 0x40F4
#define TN40_REG_TXF_RPTR_2 0x40F8
#define TN40_REG_TXF_RPTR_3 0x40FC

/* Hardware versioning */
#define TN40_FPGA_VER 0x5030

/* Registers from 0x0100-0x0150 were remapped to 0x5100-0x5150 */
#define TN40_REG_ISR TN40_REG_ISR0
#define TN40_REG_ISR0 0x5100

#define TN40_REG_IMR TN40_REG_IMR0
#define TN40_REG_IMR0 0x5110

#define TN40_REG_RDINTCM0 0x5120
#define TN40_REG_RDINTCM2 0x5128

#define TN40_REG_TDINTCM0 0x5130

#define TN40_REG_ISR_MSK0 0x5140

#define TN40_REG_INIT_SEMAPHORE 0x5170
#define TN40_REG_INIT_STATUS 0x5180

#define TN40_REG_MAC_LNK_STAT 0x0200
#define TN40_MAC_LINK_STAT 0x0004 /* Link state */

#define TN40_REG_BLNK_LED 0x0210

#define TN40_REG_GMAC_RXF_A 0x1240

#define TN40_REG_UNC_MAC0_A 0x1250
#define TN40_REG_UNC_MAC1_A 0x1260
#define TN40_REG_UNC_MAC2_A 0x1270

#define TN40_REG_VLAN_0 0x1800

#define TN40_REG_MAX_FRAME_A 0x12C0

#define TN40_REG_RX_MAC_MCST0 0x1A80
#define TN40_REG_RX_MAC_MCST1 0x1A84
#define TN40_MAC_MCST_NUM 15
#define TN40_REG_RX_MCST_HASH0 0x1A00
#define TN40_MAC_MCST_HASH_NUM 8

#define TN40_REG_VPC 0x2300
#define TN40_REG_VIC 0x2320
#define TN40_REG_VGLB 0x2340

#define TN40_REG_CLKPLL 0x5000

/* MDIO interface */

#define TN40_REG_MDIO_CMD_STAT 0x6030
#define TN40_REG_MDIO_CMD 0x6034
#define TN40_REG_MDIO_DATA 0x6038
#define TN40_REG_MDIO_ADDR 0x603C
#define TN40_GET_MDIO_BUSY(x) FIELD_GET(GENMASK(0, 0), (x))
#define TN40_GET_MDIO_RD_ERR(x) FIELD_GET(GENMASK(1, 1), (x))

#define TN40_REG_REVISION 0x6000
#define TN40_REG_SCRATCH 0x6004
#define TN40_REG_CTRLST 0x6008
#define TN40_REG_MAC_ADDR_0 0x600C
#define TN40_REG_MAC_ADDR_1 0x6010
#define TN40_REG_FRM_LENGTH 0x6014
#define TN40_REG_PAUSE_QUANT 0x6054
#define TN40_REG_RX_FIFO_SECTION 0x601C
#define TN40_REG_TX_FIFO_SECTION 0x6020
#define TN40_REG_RX_FULLNESS 0x6024
#define TN40_REG_TX_FULLNESS 0x6028
#define TN40_REG_HASHTABLE 0x602C

#define TN40_REG_RST_PORT 0x7000
#define TN40_REG_DIS_PORT 0x7010
#define TN40_REG_RST_QU 0x7020
#define TN40_REG_DIS_QU 0x7030

#define TN40_REG_CTRLST_TX_ENA 0x0001
#define TN40_REG_CTRLST_RX_ENA 0x0002
#define TN40_REG_CTRLST_PRM_ENA 0x0010
#define TN40_REG_CTRLST_PAD_ENA 0x0020

#define TN40_REG_CTRLST_BASE (TN40_REG_CTRLST_PAD_ENA | REG_CTRLST_PRM_ENA)

/* TXD TXF RXF RXD  CONFIG 0x0000 --- 0x007c */
#define TN40_TX_RX_CFG1_BASE 0xffffffff /*0-31 */
#define TN40_TX_RX_CFG0_BASE 0xfffff000 /*31:12 */
#define TN40_TX_RX_CFG0_RSVD 0x00000ffc /*11:2 */
#define TN40_TX_RX_CFG0_SIZE 0x00000003 /*1:0 */

/* TXD TXF RXF RXD  WRITE 0x0080 --- 0x00BC */
#define TN40_TXF_WPTR_WR_PTR 0x00007ff8 /*14:3 */

/* TXD TXF RXF RXD  READ  0x00CO --- 0x00FC */
#define TN40_TXF_RPTR_RD_PTR 0x00007ff8 /*14:3 */

/* The last 4 bits are dropped size is rounded to 16 */
#define TN40_TXF_WPTR_MASK 0x7ff0

/* regISR 0x0100 */
/* regIMR 0x0110 */
#define TN40_IMR_INPROG 0x80000000 /*31 */
#define TN40_IR_LNKCHG1 0x10000000 /*28 */
#define TN40_IR_LNKCHG0 0x08000000 /*27 */
#define TN40_IR_GPIO 0x04000000 /*26 */
#define TN40_IR_RFRSH 0x02000000 /*25 */
#define TN40_IR_RSVD 0x01000000 /*24 */
#define TN40_IR_SWI 0x00800000 /*23 */
#define TN40_IR_RX_FREE_3 0x00400000 /*22 */
#define TN40_IR_RX_FREE_2 0x00200000 /*21 */
#define TN40_IR_RX_FREE_1 0x00100000 /*20 */
#define TN40_IR_RX_FREE_0 0x00080000 /*19 */
#define TN40_IR_TX_FREE_3 0x00040000 /*18 */
#define TN40_IR_TX_FREE_2 0x00020000 /*17 */
#define TN40_IR_TX_FREE_1 0x00010000 /*16 */
#define TN40_IR_TX_FREE_0 0x00008000 /*15 */
#define TN40_IR_RX_DESC_3 0x00004000 /*14 */
#define TN40_IR_RX_DESC_2 0x00002000 /*13 */
#define TN40_IR_RX_DESC_1 0x00001000 /*12 */
#define TN40_IR_RX_DESC_0 0x00000800 /*11 */
#define TN40_IR_PSE 0x00000400 /*10 */
#define TN40_IR_TMR3 0x00000200 /* 9 */
#define TN40_IR_TMR2 0x00000100 /* 8 */
#define TN40_IR_TMR1 0x00000080 /* 7 */
#define TN40_IR_TMR0 0x00000040 /* 6 */
#define TN40_IR_VNT 0x00000020 /* 5 */
#define TN40_IR_RxFL 0x00000010 /* 4 */
#define TN40_IR_SDPERR 0x00000008 /* 3 */
#define TN40_IR_TR 0x00000004 /* 2 */
#define TN40_IR_PCIE_LINK 0x00000002 /* 1 */
#define TN40_IR_PCIE_TOUT 0x00000001 /* 0 */

#define TN40_IR_EXTRA						\
	(TN40_IR_RX_FREE_0 | TN40_IR_LNKCHG0 | TN40_IR_LNKCHG1 |\
	TN40_IR_PSE | TN40_IR_TMR0 | TN40_IR_PCIE_LINK |	\
	TN40_IR_PCIE_TOUT)

#define TN40_GMAC_RX_FILTER_OSEN 0x1000 /* shared OS enable */
#define TN40_GMAC_RX_FILTER_TXFC 0x0400 /* Tx flow control */
#define TN40_GMAC_RX_FILTER_RSV0 0x0200 /* reserved */
#define TN40_GMAC_RX_FILTER_FDA 0x0100 /* filter out direct address */
#define TN40_GMAC_RX_FILTER_AOF 0x0080 /* accept over run */
#define TN40_GMAC_RX_FILTER_ACF 0x0040 /* accept control frames */
#define TN40_GMAC_RX_FILTER_ARUNT 0x0020 /* accept under run */
#define TN40_GMAC_RX_FILTER_ACRC 0x0010 /* accept crc error */
#define TN40_GMAC_RX_FILTER_AM 0x0008 /* accept multicast */
#define TN40_GMAC_RX_FILTER_AB 0x0004 /* accept broadcast */
#define TN40_GMAC_RX_FILTER_PRM 0x0001 /* [0:1] promiscuous mode */

#define TN40_MAX_FRAME_AB_VAL 0x3fff /* 13:0 */

#define TN40_CLKPLL_PLLLKD 0x0200 /* 9 */
#define TN40_CLKPLL_RSTEND 0x0100 /* 8 */
#define TN40_CLKPLL_SFTRST 0x0001 /* 0 */

#define TN40_CLKPLL_LKD (TN40_CLKPLL_PLLLKD | TN40_CLKPLL_RSTEND)

#endif