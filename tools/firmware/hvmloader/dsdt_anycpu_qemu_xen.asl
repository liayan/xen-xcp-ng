/******************************************************************************
 * DSDT for Xen with Qemu device model
 *
 * Copyright (c) 2004, Intel Corporation.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "Xen", "HVM", 0)
{
    Name (\PMBS, 0x0C00)
    Name (\PMLN, 0x08)
    Name (\IOB1, 0x00)
    Name (\IOL1, 0x00)
    Name (\APCB, 0xFEC00000)
    Name (\APCL, 0x00010000)
    Name (\PUID, 0x00)


    Scope (\_SB)
    {

        /* Fix HCT test for 0x400 pci memory:
         * - need to report low 640 MB mem as motherboard resource
         */
       Device(MEM0)
       {
           Name(_HID, EISAID("PNP0C02"))
           Name(_CRS, ResourceTemplate() {
               QWordMemory(
                    ResourceConsumer, PosDecode, MinFixed,
                    MaxFixed, Cacheable, ReadWrite,
                    0x00000000,
                    0x00000000,
                    0x0009ffff,
                    0x00000000,
                    0x000a0000)
           })
       }

       Device (PCI0)
       {
           Name (_HID, EisaId ("PNP0A03"))
           Name (_UID, 0x00)
           Name (_ADR, 0x00)
           Name (_BBN, 0x00)

           /* Make cirrues VGA S3 suspend/resume work in Windows XP/2003 */
           Device (VGA)
           {
               Name (_ADR, 0x00020000)

               Method (_S1D, 0, NotSerialized)
               {
                   Return (0x00)
               }
               Method (_S2D, 0, NotSerialized)
               {
                   Return (0x00)
               }
               Method (_S3D, 0, NotSerialized)
               {
                   Return (0x00)
               }
           }

           Method (_CRS, 0, NotSerialized)
           {
               Store (ResourceTemplate ()
               {
                   /* bus number is from 0 - 255*/
                   WordBusNumber(
                        ResourceProducer, MinFixed, MaxFixed, SubDecode,
                        0x0000,
                        0x0000,
                        0x00FF,
                        0x0000,
                        0x0100)
                    IO (Decode16, 0x0CF8, 0x0CF8, 0x01, 0x08)
                    WordIO(
                        ResourceProducer, MinFixed, MaxFixed, PosDecode,
                        EntireRange,
                        0x0000,
                        0x0000,
                        0x0CF7,
                        0x0000,
                        0x0CF8)
                    WordIO(
                        ResourceProducer, MinFixed, MaxFixed, PosDecode,
                        EntireRange,
                        0x0000,
                        0x0D00,
                        0xFFFF,
                        0x0000,
                        0xF300)

                    /* reserve memory for pci devices */
                    DWordMemory(
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        WriteCombining, ReadWrite,
                        0x00000000,
                        0x000A0000,
                        0x000BFFFF,
                        0x00000000,
                        0x00020000)

                    DWordMemory(
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x00000000,
                        0xF0000000,
                        0xF4FFFFFF,
                        0x00000000,
                        0x05000000,
                        ,, _Y01)

                    QWordMemory (
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x0000000000000000,
                        0x0000000FFFFFFFF0,
                        0x0000000FFFFFFFFF,
                        0x0000000000000000,
                        0x0000000000000010,
                        ,, _Y02)

                }, Local1)

                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._MIN, MMIN)
                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._MAX, MMAX)
                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._LEN, MLEN)

                Store(\_SB.PMIN, MMIN)
                Store(\_SB.PLEN, MLEN)
                Add(MMIN, MLEN, MMAX)
                Subtract(MMAX, One, MMAX)

                /*
                 * WinXP / Win2K3 blue-screen for operations on 64-bit values.
                 * Therefore we need to split the 64-bit calculations needed
                 * here, but different iasl versions evaluate name references
                 * to integers differently:
                 * Year (approximate)          2006    2008    2012
                 * \_SB.PCI0._CRS._Y02         zero   valid   valid
                 * \_SB.PCI0._CRS._Y02._MIN   valid   valid    huge
                 */
                If(LEqual(Zero, \_SB.PCI0._CRS._Y02)) {
                    Subtract(\_SB.PCI0._CRS._Y02._MIN, 14, Local0)
                } Else {
                    Store(\_SB.PCI0._CRS._Y02, Local0)
                }
                CreateDWordField(Local1, Add(Local0, 14), MINL)
                CreateDWordField(Local1, Add(Local0, 18), MINH)
                CreateDWordField(Local1, Add(Local0, 22), MAXL)
                CreateDWordField(Local1, Add(Local0, 26), MAXH)
                CreateDWordField(Local1, Add(Local0, 38), LENL)
                CreateDWordField(Local1, Add(Local0, 42), LENH)

                Store(\_SB.LMIN, MINL)
                Store(\_SB.HMIN, MINH)
                Store(\_SB.LLEN, LENL)
                Store(\_SB.HLEN, LENH)
                Add(MINL, LENL, MAXL)
                Add(MINH, LENH, MAXH)
                If(LLess(MAXL, MINL)) {
                    Add(MAXH, One, MAXH)
                }
                If(LOr(MINH, LENL)) {
                    If(LEqual(MAXL, 0)) {
                        Subtract(MAXH, One, MAXH)
                    }
                    Subtract(MAXL, One, MAXL)
                }

                Return (Local1)
            }

            Device(HPET) {
                Name(_HID,  EISAID("PNP0103"))
                Name(_UID, 0)
                Method (_STA, 0, NotSerialized) {
                    If(LEqual(\_SB.HPET, 0)) {
                        Return(0x00)
                    } Else {
                        Return(0x0F)
                    }
                }
                Name(_CRS, ResourceTemplate() {
                    DWordMemory(
                        ResourceConsumer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x00000000,
                        0xFED00000,
                        0xFED003FF,
                        0x00000000,
                        0x00000400 /* 1K memory: FED00000 - FED003FF */
                    )
                })
            }

            Device (ISA)
            {
                Name (_ADR, 0x00010000) /* device 1, fn 0 */

                OperationRegion(PIRQ, PCI_Config, 0x60, 0x4)
                Scope(\) {
                    Field (\_SB.PCI0.ISA.PIRQ, ByteAcc, NoLock, Preserve) {
                        PIRA, 8,
                        PIRB, 8,
                        PIRC, 8,
                        PIRD, 8
                    }
                }
                Device (SYSR)
                {
                    Name (_HID, EisaId ("PNP0C02"))
                    Name (_UID, 0x01)
                    Name (CRS, ResourceTemplate ()
                    {
                        /* TODO: list hidden resources */
                        IO (Decode16, 0x0010, 0x0010, 0x00, 0x10)
                        IO (Decode16, 0x0022, 0x0022, 0x00, 0x0C)
                        IO (Decode16, 0x0030, 0x0030, 0x00, 0x10)
                        IO (Decode16, 0x0044, 0x0044, 0x00, 0x1C)
                        IO (Decode16, 0x0062, 0x0062, 0x00, 0x02)
                        IO (Decode16, 0x0065, 0x0065, 0x00, 0x0B)
                        IO (Decode16, 0x0072, 0x0072, 0x00, 0x0E)
                        IO (Decode16, 0x0080, 0x0080, 0x00, 0x01)
                        IO (Decode16, 0x0084, 0x0084, 0x00, 0x03)
                        IO (Decode16, 0x0088, 0x0088, 0x00, 0x01)
                        IO (Decode16, 0x008C, 0x008C, 0x00, 0x03)
                        IO (Decode16, 0x0090, 0x0090, 0x00, 0x10)
                        IO (Decode16, 0x00A2, 0x00A2, 0x00, 0x1C)
                        IO (Decode16, 0x00E0, 0x00E0, 0x00, 0x10)
                        IO (Decode16, 0x08A0, 0x08A0, 0x00, 0x04)
                        IO (Decode16, 0x0CC0, 0x0CC0, 0x00, 0x10)
                        IO (Decode16, 0x04D0, 0x04D0, 0x00, 0x02)
                    })
                    Method (_CRS, 0, NotSerialized)
                    {
                        Return (CRS)
                    }
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0020, 0x0020, 0x01, 0x02)
                        IO (Decode16, 0x00A0, 0x00A0, 0x01, 0x02)
                        IRQNoFlags () {2}
                    })
                }

                Device (DMA0)
                {
                    Name (_HID, EisaId ("PNP0200"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        DMA (Compatibility, BusMaster, Transfer8) {4}
                        IO (Decode16, 0x0000, 0x0000, 0x00, 0x10)
                        IO (Decode16, 0x0081, 0x0081, 0x00, 0x03)
                        IO (Decode16, 0x0087, 0x0087, 0x00, 0x01)
                        IO (Decode16, 0x0089, 0x0089, 0x00, 0x03)
                        IO (Decode16, 0x008F, 0x008F, 0x00, 0x01)
                        IO (Decode16, 0x00C0, 0x00C0, 0x00, 0x20)
                        IO (Decode16, 0x0480, 0x0480, 0x00, 0x10)
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0040, 0x0040, 0x00, 0x04)
                        IRQNoFlags () {0}
                    })
                }

                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0070, 0x0070, 0x00, 0x02)
                        IRQNoFlags () {8}
                    })
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0061, 0x0061, 0x00, 0x01)
                    })
                }

                Device (PS2M)
                {
                    Name (_HID, EisaId ("PNP0F13"))
                    Name (_CID, 0x130FD041)
                    Method (_STA, 0, NotSerialized)
                    {
                        Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IRQNoFlags () {12}
                    })
                }

                Device (PS2K)
                {
                    Name (_HID, EisaId ("PNP0303"))
                    Name (_CID, 0x0B03D041)
                    Method (_STA, 0, NotSerialized)
                    {
                        Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0060, 0x0060, 0x00, 0x01)
                        IO (Decode16, 0x0064, 0x0064, 0x00, 0x01)
                        IRQNoFlags () {1}
                    })
                }

                Device (FDC0)
                {
                    Name (_HID, EisaId ("PNP0700"))
                    Method (_STA, 0, NotSerialized)
                    {
                          Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x03F0, 0x03F0, 0x01, 0x06)
                        IO (Decode16, 0x03F7, 0x03F7, 0x01, 0x01)
                        IRQNoFlags () {6}
                        DMA (Compatibility, NotBusMaster, Transfer8) {2}
                    })
                }

                Device (UAR1)
                {
                    Name (_HID, EisaId ("PNP0501"))
                    Name (_UID, 0x01)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.UAR1, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x03F8, 0x03F8, 8, 8)
                        IRQNoFlags () {4}
                    })
                }

                Device (UAR2)
                {
                    Name (_HID, EisaId ("PNP0501"))
                    Name (_UID, 0x02)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.UAR2, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x02F8, 0x02F8, 8, 8)
                        IRQNoFlags () {3}
                    })
                }

                Device (LTP1)
                {
                    Name (_HID, EisaId ("PNP0400"))
                    Name (_UID, 0x02)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.LTP1, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x0378, 0x0378, 0x08, 0x08)
                        IRQNoFlags () {7}
                    })
                }

                Device(VGID) {
                    Name(_HID, EisaId ("XEN0000"))
                    Name(_UID, 0x00)
                    Name(_CID, "VM_Gen_Counter")
                    Name(_DDN, "VM_Gen_Counter")
                    Method(_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.VGIA, 0x00000000)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }
                    Name(PKG, Package ()
                    {
                        0x00000000,
                        0x00000000
                    })
                    Method(ADDR, 0, NotSerialized)
                    {
                        Store(\_SB.VGIA, Index(PKG, 0))
                        Return(PKG)
                    }
                }
            }
        }
    }
    /* _S3 and _S4 are in separate SSDTs */
    Name (\_S5, Package (0x04) {
        0x00,  /* PM1a_CNT.SLP_TYP */
        0x00,  /* PM1b_CNT.SLP_TYP */
        0x00,  /* reserved */
        0x00   /* reserved */
    })
    Name(PICD, 0)
    Method(_PIC, 1) {
        Store(Arg0, PICD)
    }

    Scope (\_SB)
    {
       /*
        * BIOS region must match struct acpi_info in build.c and
        * be located at ACPI_INFO_PHYSICAL_ADDRESS = 0xFC000000
        */
       OperationRegion(BIOS, SystemMemory, 0xFC000000, 40)
       Field(BIOS, ByteAcc, NoLock, Preserve) {
           UAR1, 1,
           UAR2, 1,
           LTP1, 1,
           HPET, 1,
           Offset(2),
           NCPU, 16,
           PMIN, 32,
           PLEN, 32,
           MSUA, 32, /* MADT checksum address */
           MAPA, 32, /* MADT LAPIC0 address */
           VGIA, 32, /* VM generation id address */
           LMIN, 32,
           HMIN, 32,
           LLEN, 32,
           HLEN, 32
       }
    }
    Scope ( \_SB ) {
        OperationRegion ( MSUM, SystemMemory, \_SB.MSUA, 1 )
        Field ( MSUM, ByteAcc, NoLock, Preserve ) {
            MSU, 8
        }
        Method ( PMAT, 2 ) {
            If ( LLess(Arg0, NCPU) ) {
                Return ( ToBuffer(Arg1) )
            }
            Return ( Buffer() {0, 8, 0xff, 0xff, 0, 0, 0, 0} )
        }
        Processor ( PR00, 0, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 0 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 0), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR01, 1, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 1 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 8), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (1, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(1, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR02, 2, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 2 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 16), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (2, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(2, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR03, 3, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 3 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 24), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (3, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(3, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR04, 4, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 4 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 32), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (4, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(4, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR05, 5, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 5 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 40), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (5, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(5, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR06, 6, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 6 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 48), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (6, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(6, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR07, 7, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 7 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 56), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (7, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(7, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR08, 8, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 8 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 64), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (8, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(8, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR09, 9, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 9 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 72), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (9, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(9, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0A, 10, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 10 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 80), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (10, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(10, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0B, 11, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 11 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 88), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (11, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(11, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0C, 12, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 12 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 96), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (12, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(12, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0D, 13, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 13 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 104), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (13, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(13, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0E, 14, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 14 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 112), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (14, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(14, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0F, 15, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 15 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 120), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (15, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(15, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR10, 16, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 16 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 128), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (16, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(16, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR11, 17, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 17 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 136), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (17, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(17, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR12, 18, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 18 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 144), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (18, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(18, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR13, 19, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 19 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 152), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (19, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(19, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR14, 20, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 20 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 160), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (20, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(20, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR15, 21, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 21 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 168), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (21, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(21, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR16, 22, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 22 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 176), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (22, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(22, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR17, 23, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 23 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 184), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (23, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(23, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR18, 24, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 24 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 192), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (24, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(24, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR19, 25, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 25 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 200), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (25, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(25, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1A, 26, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 26 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 208), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (26, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(26, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1B, 27, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 27 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 216), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (27, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(27, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1C, 28, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 28 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 224), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (28, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(28, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1D, 29, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 29 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 232), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (29, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(29, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1E, 30, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 30 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 240), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (30, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(30, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1F, 31, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 31 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 248), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (31, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(31, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR20, 32, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 32 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 256), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (32, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(32, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR21, 33, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 33 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 264), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (33, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(33, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR22, 34, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 34 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 272), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (34, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(34, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR23, 35, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 35 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 280), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (35, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(35, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR24, 36, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 36 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 288), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (36, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(36, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR25, 37, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 37 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 296), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (37, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(37, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR26, 38, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 38 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 304), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (38, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(38, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR27, 39, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 39 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 312), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (39, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(39, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR28, 40, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 40 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 320), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (40, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(40, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR29, 41, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 41 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 328), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (41, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(41, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2A, 42, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 42 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 336), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (42, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(42, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2B, 43, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 43 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 344), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (43, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(43, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2C, 44, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 44 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 352), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (44, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(44, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2D, 45, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 45 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 360), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (45, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(45, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2E, 46, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 46 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 368), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (46, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(46, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2F, 47, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 47 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 376), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (47, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(47, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR30, 48, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 48 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 384), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (48, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(48, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR31, 49, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 49 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 392), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (49, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(49, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR32, 50, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 50 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 400), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (50, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(50, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR33, 51, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 51 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 408), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (51, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(51, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR34, 52, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 52 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 416), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (52, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(52, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR35, 53, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 53 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 424), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (53, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(53, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR36, 54, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 54 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 432), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (54, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(54, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR37, 55, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 55 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 440), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (55, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(55, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR38, 56, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 56 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 448), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (56, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(56, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR39, 57, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 57 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 456), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (57, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(57, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3A, 58, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 58 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 464), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (58, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(58, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3B, 59, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 59 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 472), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (59, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(59, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3C, 60, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 60 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 480), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (60, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(60, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3D, 61, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 61 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 488), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (61, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(61, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3E, 62, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 62 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 496), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (62, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(62, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3F, 63, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 63 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 504), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (63, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(63, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR40, 64, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 64 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 512), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (64, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(64, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR41, 65, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 65 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 520), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (65, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(65, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR42, 66, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 66 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 528), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (66, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(66, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR43, 67, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 67 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 536), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (67, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(67, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR44, 68, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 68 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 544), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (68, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(68, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR45, 69, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 69 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 552), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (69, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(69, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR46, 70, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 70 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 560), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (70, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(70, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR47, 71, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 71 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 568), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (71, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(71, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR48, 72, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 72 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 576), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (72, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(72, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR49, 73, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 73 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 584), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (73, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(73, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4A, 74, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 74 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 592), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (74, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(74, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4B, 75, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 75 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 600), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (75, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(75, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4C, 76, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 76 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 608), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (76, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(76, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4D, 77, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 77 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 616), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (77, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(77, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4E, 78, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 78 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 624), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (78, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(78, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4F, 79, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 79 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 632), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (79, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(79, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR50, 80, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 80 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 640), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (80, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(80, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR51, 81, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 81 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 648), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (81, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(81, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR52, 82, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 82 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 656), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (82, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(82, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR53, 83, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 83 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 664), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (83, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(83, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR54, 84, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 84 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 672), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (84, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(84, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR55, 85, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 85 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 680), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (85, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(85, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR56, 86, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 86 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 688), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (86, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(86, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR57, 87, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 87 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 696), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (87, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(87, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR58, 88, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 88 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 704), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (88, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(88, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR59, 89, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 89 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 712), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (89, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(89, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5A, 90, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 90 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 720), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (90, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(90, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5B, 91, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 91 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 728), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (91, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(91, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5C, 92, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 92 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 736), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (92, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(92, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5D, 93, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 93 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 744), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (93, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(93, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5E, 94, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 94 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 752), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (94, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(94, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5F, 95, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 95 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 760), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (95, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(95, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR60, 96, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 96 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 768), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (96, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(96, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR61, 97, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 97 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 776), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (97, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(97, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR62, 98, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 98 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 784), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (98, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(98, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR63, 99, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 99 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 792), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (99, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(99, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR64, 100, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 100 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 800), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (100, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(100, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR65, 101, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 101 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 808), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (101, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(101, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR66, 102, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 102 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 816), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (102, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(102, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR67, 103, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 103 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 824), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (103, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(103, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR68, 104, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 104 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 832), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (104, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(104, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR69, 105, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 105 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 840), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (105, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(105, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6A, 106, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 106 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 848), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (106, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(106, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6B, 107, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 107 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 856), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (107, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(107, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6C, 108, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 108 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 864), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (108, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(108, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6D, 109, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 109 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 872), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (109, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(109, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6E, 110, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 110 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 880), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (110, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(110, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6F, 111, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 111 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 888), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (111, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(111, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR70, 112, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 112 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 896), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (112, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(112, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR71, 113, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 113 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 904), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (113, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(113, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR72, 114, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 114 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 912), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (114, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(114, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR73, 115, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 115 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 920), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (115, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(115, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR74, 116, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 116 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 928), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (116, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(116, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR75, 117, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 117 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 936), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (117, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(117, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR76, 118, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 118 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 944), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (118, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(118, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR77, 119, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 119 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 952), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (119, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(119, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR78, 120, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 120 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 960), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (120, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(120, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR79, 121, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 121 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 968), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (121, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(121, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7A, 122, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 122 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 976), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (122, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(122, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7B, 123, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 123 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 984), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (123, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(123, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7C, 124, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 124 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 992), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (124, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(124, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7D, 125, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 125 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1000), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (125, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(125, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7E, 126, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 126 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1008), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (126, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(126, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7F, 127, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            Name ( _UID, 127 )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1016), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( PMAT (127, MAT) )
            }
            Method ( _STA ) {
                If ( LLess(127, \_SB.NCPU) ) {
                    If ( FLG ) {
                        Return ( 0xF )
                    }
                }
                Return ( 0x0 )
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        OperationRegion ( PRST, SystemIO, 0xaf00, 16 )
        Field ( PRST, ByteAcc, NoLock, Preserve ) {
            PRS, 128
        }
        Method ( PRSC, 0 ) {
            Store ( ToBuffer(PRS), Local0 )
            Store ( DerefOf(Index(Local0, 0)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR00.FLG) ) {
                Store ( Local2, \_SB.PR00.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR00, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR00, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR01.FLG) ) {
                Store ( Local2, \_SB.PR01.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR01, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR01, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR02.FLG) ) {
                Store ( Local2, \_SB.PR02.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR02, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR02, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR03.FLG) ) {
                Store ( Local2, \_SB.PR03.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR03, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR03, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR04.FLG) ) {
                Store ( Local2, \_SB.PR04.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR04, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR04, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR05.FLG) ) {
                Store ( Local2, \_SB.PR05.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR05, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR05, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR06.FLG) ) {
                Store ( Local2, \_SB.PR06.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR06, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR06, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR07.FLG) ) {
                Store ( Local2, \_SB.PR07.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR07, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR07, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 1)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR08.FLG) ) {
                Store ( Local2, \_SB.PR08.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR08, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR08, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR09.FLG) ) {
                Store ( Local2, \_SB.PR09.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR09, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR09, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0A.FLG) ) {
                Store ( Local2, \_SB.PR0A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0B.FLG) ) {
                Store ( Local2, \_SB.PR0B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0C.FLG) ) {
                Store ( Local2, \_SB.PR0C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0D.FLG) ) {
                Store ( Local2, \_SB.PR0D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0E.FLG) ) {
                Store ( Local2, \_SB.PR0E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0F.FLG) ) {
                Store ( Local2, \_SB.PR0F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 2)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR10.FLG) ) {
                Store ( Local2, \_SB.PR10.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR10, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR10, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR11.FLG) ) {
                Store ( Local2, \_SB.PR11.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR11, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR11, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR12.FLG) ) {
                Store ( Local2, \_SB.PR12.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR12, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR12, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR13.FLG) ) {
                Store ( Local2, \_SB.PR13.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR13, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR13, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR14.FLG) ) {
                Store ( Local2, \_SB.PR14.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR14, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR14, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR15.FLG) ) {
                Store ( Local2, \_SB.PR15.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR15, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR15, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR16.FLG) ) {
                Store ( Local2, \_SB.PR16.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR16, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR16, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR17.FLG) ) {
                Store ( Local2, \_SB.PR17.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR17, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR17, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 3)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR18.FLG) ) {
                Store ( Local2, \_SB.PR18.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR18, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR18, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR19.FLG) ) {
                Store ( Local2, \_SB.PR19.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR19, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR19, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1A.FLG) ) {
                Store ( Local2, \_SB.PR1A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1B.FLG) ) {
                Store ( Local2, \_SB.PR1B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1C.FLG) ) {
                Store ( Local2, \_SB.PR1C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1D.FLG) ) {
                Store ( Local2, \_SB.PR1D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1E.FLG) ) {
                Store ( Local2, \_SB.PR1E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1F.FLG) ) {
                Store ( Local2, \_SB.PR1F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 4)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR20.FLG) ) {
                Store ( Local2, \_SB.PR20.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR20, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR20, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR21.FLG) ) {
                Store ( Local2, \_SB.PR21.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR21, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR21, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR22.FLG) ) {
                Store ( Local2, \_SB.PR22.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR22, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR22, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR23.FLG) ) {
                Store ( Local2, \_SB.PR23.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR23, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR23, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR24.FLG) ) {
                Store ( Local2, \_SB.PR24.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR24, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR24, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR25.FLG) ) {
                Store ( Local2, \_SB.PR25.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR25, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR25, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR26.FLG) ) {
                Store ( Local2, \_SB.PR26.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR26, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR26, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR27.FLG) ) {
                Store ( Local2, \_SB.PR27.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR27, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR27, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 5)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR28.FLG) ) {
                Store ( Local2, \_SB.PR28.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR28, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR28, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR29.FLG) ) {
                Store ( Local2, \_SB.PR29.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR29, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR29, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2A.FLG) ) {
                Store ( Local2, \_SB.PR2A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2B.FLG) ) {
                Store ( Local2, \_SB.PR2B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2C.FLG) ) {
                Store ( Local2, \_SB.PR2C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2D.FLG) ) {
                Store ( Local2, \_SB.PR2D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2E.FLG) ) {
                Store ( Local2, \_SB.PR2E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2F.FLG) ) {
                Store ( Local2, \_SB.PR2F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 6)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR30.FLG) ) {
                Store ( Local2, \_SB.PR30.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR30, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR30, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR31.FLG) ) {
                Store ( Local2, \_SB.PR31.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR31, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR31, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR32.FLG) ) {
                Store ( Local2, \_SB.PR32.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR32, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR32, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR33.FLG) ) {
                Store ( Local2, \_SB.PR33.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR33, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR33, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR34.FLG) ) {
                Store ( Local2, \_SB.PR34.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR34, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR34, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR35.FLG) ) {
                Store ( Local2, \_SB.PR35.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR35, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR35, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR36.FLG) ) {
                Store ( Local2, \_SB.PR36.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR36, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR36, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR37.FLG) ) {
                Store ( Local2, \_SB.PR37.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR37, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR37, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 7)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR38.FLG) ) {
                Store ( Local2, \_SB.PR38.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR38, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR38, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR39.FLG) ) {
                Store ( Local2, \_SB.PR39.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR39, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR39, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3A.FLG) ) {
                Store ( Local2, \_SB.PR3A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3B.FLG) ) {
                Store ( Local2, \_SB.PR3B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3C.FLG) ) {
                Store ( Local2, \_SB.PR3C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3D.FLG) ) {
                Store ( Local2, \_SB.PR3D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3E.FLG) ) {
                Store ( Local2, \_SB.PR3E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3F.FLG) ) {
                Store ( Local2, \_SB.PR3F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 8)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR40.FLG) ) {
                Store ( Local2, \_SB.PR40.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR40, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR40, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR41.FLG) ) {
                Store ( Local2, \_SB.PR41.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR41, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR41, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR42.FLG) ) {
                Store ( Local2, \_SB.PR42.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR42, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR42, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR43.FLG) ) {
                Store ( Local2, \_SB.PR43.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR43, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR43, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR44.FLG) ) {
                Store ( Local2, \_SB.PR44.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR44, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR44, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR45.FLG) ) {
                Store ( Local2, \_SB.PR45.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR45, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR45, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR46.FLG) ) {
                Store ( Local2, \_SB.PR46.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR46, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR46, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR47.FLG) ) {
                Store ( Local2, \_SB.PR47.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR47, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR47, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 9)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR48.FLG) ) {
                Store ( Local2, \_SB.PR48.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR48, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR48, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR49.FLG) ) {
                Store ( Local2, \_SB.PR49.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR49, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR49, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4A.FLG) ) {
                Store ( Local2, \_SB.PR4A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4B.FLG) ) {
                Store ( Local2, \_SB.PR4B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4C.FLG) ) {
                Store ( Local2, \_SB.PR4C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4D.FLG) ) {
                Store ( Local2, \_SB.PR4D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4E.FLG) ) {
                Store ( Local2, \_SB.PR4E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4F.FLG) ) {
                Store ( Local2, \_SB.PR4F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 10)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR50.FLG) ) {
                Store ( Local2, \_SB.PR50.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR50, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR50, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR51.FLG) ) {
                Store ( Local2, \_SB.PR51.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR51, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR51, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR52.FLG) ) {
                Store ( Local2, \_SB.PR52.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR52, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR52, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR53.FLG) ) {
                Store ( Local2, \_SB.PR53.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR53, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR53, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR54.FLG) ) {
                Store ( Local2, \_SB.PR54.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR54, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR54, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR55.FLG) ) {
                Store ( Local2, \_SB.PR55.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR55, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR55, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR56.FLG) ) {
                Store ( Local2, \_SB.PR56.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR56, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR56, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR57.FLG) ) {
                Store ( Local2, \_SB.PR57.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR57, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR57, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 11)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR58.FLG) ) {
                Store ( Local2, \_SB.PR58.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR58, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR58, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR59.FLG) ) {
                Store ( Local2, \_SB.PR59.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR59, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR59, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5A.FLG) ) {
                Store ( Local2, \_SB.PR5A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5B.FLG) ) {
                Store ( Local2, \_SB.PR5B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5C.FLG) ) {
                Store ( Local2, \_SB.PR5C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5D.FLG) ) {
                Store ( Local2, \_SB.PR5D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5E.FLG) ) {
                Store ( Local2, \_SB.PR5E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5F.FLG) ) {
                Store ( Local2, \_SB.PR5F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 12)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR60.FLG) ) {
                Store ( Local2, \_SB.PR60.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR60, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR60, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR61.FLG) ) {
                Store ( Local2, \_SB.PR61.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR61, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR61, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR62.FLG) ) {
                Store ( Local2, \_SB.PR62.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR62, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR62, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR63.FLG) ) {
                Store ( Local2, \_SB.PR63.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR63, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR63, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR64.FLG) ) {
                Store ( Local2, \_SB.PR64.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR64, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR64, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR65.FLG) ) {
                Store ( Local2, \_SB.PR65.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR65, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR65, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR66.FLG) ) {
                Store ( Local2, \_SB.PR66.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR66, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR66, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR67.FLG) ) {
                Store ( Local2, \_SB.PR67.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR67, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR67, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 13)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR68.FLG) ) {
                Store ( Local2, \_SB.PR68.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR68, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR68, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR69.FLG) ) {
                Store ( Local2, \_SB.PR69.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR69, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR69, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6A.FLG) ) {
                Store ( Local2, \_SB.PR6A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6B.FLG) ) {
                Store ( Local2, \_SB.PR6B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6C.FLG) ) {
                Store ( Local2, \_SB.PR6C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6D.FLG) ) {
                Store ( Local2, \_SB.PR6D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6E.FLG) ) {
                Store ( Local2, \_SB.PR6E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6F.FLG) ) {
                Store ( Local2, \_SB.PR6F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 14)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR70.FLG) ) {
                Store ( Local2, \_SB.PR70.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR70, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR70, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR71.FLG) ) {
                Store ( Local2, \_SB.PR71.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR71, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR71, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR72.FLG) ) {
                Store ( Local2, \_SB.PR72.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR72, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR72, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR73.FLG) ) {
                Store ( Local2, \_SB.PR73.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR73, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR73, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR74.FLG) ) {
                Store ( Local2, \_SB.PR74.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR74, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR74, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR75.FLG) ) {
                Store ( Local2, \_SB.PR75.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR75, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR75, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR76.FLG) ) {
                Store ( Local2, \_SB.PR76.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR76, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR76, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR77.FLG) ) {
                Store ( Local2, \_SB.PR77.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR77, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR77, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 15)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR78.FLG) ) {
                Store ( Local2, \_SB.PR78.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR78, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR78, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR79.FLG) ) {
                Store ( Local2, \_SB.PR79.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR79, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR79, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7A.FLG) ) {
                Store ( Local2, \_SB.PR7A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7B.FLG) ) {
                Store ( Local2, \_SB.PR7B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7C.FLG) ) {
                Store ( Local2, \_SB.PR7C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7D.FLG) ) {
                Store ( Local2, \_SB.PR7D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7E.FLG) ) {
                Store ( Local2, \_SB.PR7E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7F.FLG) ) {
                Store ( Local2, \_SB.PR7F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Return ( One )
        }
    }
    Scope ( \_GPE ) {
        Method ( _E02 ) {
            \_SB.PRSC ()
        }
    }
    Scope ( \_SB.PCI0 ) {
        Device ( HP0 ) {
            Name ( _HID, EISAID("PNP0C02") )
            Name ( _CRS, ResourceTemplate() {  IO (Decode16, 0xae00, 0xae00, 0x00, 0x10)  IO (Decode16, 0xb044, 0xb044, 0x00, 0x04)} )
        }
        Name ( BUFA, ResourceTemplate() { IRQ(Level, ActiveLow, Shared) { 5, 10, 11 } } )
        Name ( BUFB, Buffer() { 0x23, 0x00, 0x00, 0x18, 0x79, 0 } )
        CreateWordField ( BUFB, 0x01, IRQV )
        Device ( LNKA ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 1 )
            Method ( _STA, 0 ) {
                If ( And(PIRA, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRA, 0x80, PIRA )
            }
            Method ( _CRS ) {
                And ( PIRA, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRA )
            }
        }
        Device ( LNKB ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 2 )
            Method ( _STA, 0 ) {
                If ( And(PIRB, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRB, 0x80, PIRB )
            }
            Method ( _CRS ) {
                And ( PIRB, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRB )
            }
        }
        Device ( LNKC ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 3 )
            Method ( _STA, 0 ) {
                If ( And(PIRC, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRC, 0x80, PIRC )
            }
            Method ( _CRS ) {
                And ( PIRC, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRC )
            }
        }
        Device ( LNKD ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 4 )
            Method ( _STA, 0 ) {
                If ( And(PIRD, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRD, 0x80, PIRD )
            }
            Method ( _CRS ) {
                And ( PIRD, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRD )
            }
        }
        Method ( _PRT, 0 ) {
            If ( PICD ) {
                Return ( PRTA )
            }
            Return ( PRTP )
        }
Name(PRTP, Package() {
Package(){0x0001ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0001ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0001ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0001ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0002ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0002ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0002ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0002ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0003ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0003ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0003ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0003ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0004ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0004ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0004ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0004ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0005ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0005ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0005ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0005ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0006ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0006ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0006ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0006ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0007ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0007ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0007ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0007ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0008ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0008ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0008ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0008ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0009ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0009ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0009ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0009ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x000affff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x000affff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x000affff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x000affff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x000bffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x000bffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x000bffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x000bffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x000cffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x000cffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x000cffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x000cffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x000dffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x000dffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x000dffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x000dffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x000effff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x000effff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x000effff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x000effff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x000fffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x000fffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x000fffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x000fffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0010ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0010ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0010ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0010ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0011ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0011ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0011ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0011ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0012ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0012ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0012ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0012ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0013ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0013ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0013ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0013ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0014ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0014ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0014ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0014ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0015ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0015ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0015ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0015ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0016ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0016ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0016ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0016ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0017ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0017ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0017ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0017ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0018ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0018ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0018ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0018ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0019ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0019ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0019ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0019ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x001affff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x001affff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x001affff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x001affff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x001bffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x001bffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x001bffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x001bffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x001cffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x001cffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x001cffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x001cffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x001dffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x001dffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x001dffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x001dffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x001effff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x001effff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x001effff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x001effff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x001fffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x001fffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x001fffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x001fffff, 3, \_SB.PCI0.LNKC, 0},
})
Name(PRTA, Package() {
Package(){0x0001ffff, 0, 0, 20},
Package(){0x0001ffff, 1, 0, 21},
Package(){0x0001ffff, 2, 0, 22},
Package(){0x0001ffff, 3, 0, 23},
Package(){0x0002ffff, 0, 0, 24},
Package(){0x0002ffff, 1, 0, 25},
Package(){0x0002ffff, 2, 0, 26},
Package(){0x0002ffff, 3, 0, 27},
Package(){0x0003ffff, 0, 0, 28},
Package(){0x0003ffff, 1, 0, 29},
Package(){0x0003ffff, 2, 0, 30},
Package(){0x0003ffff, 3, 0, 31},
Package(){0x0004ffff, 0, 0, 32},
Package(){0x0004ffff, 1, 0, 33},
Package(){0x0004ffff, 2, 0, 34},
Package(){0x0004ffff, 3, 0, 35},
Package(){0x0005ffff, 0, 0, 36},
Package(){0x0005ffff, 1, 0, 37},
Package(){0x0005ffff, 2, 0, 38},
Package(){0x0005ffff, 3, 0, 39},
Package(){0x0006ffff, 0, 0, 40},
Package(){0x0006ffff, 1, 0, 41},
Package(){0x0006ffff, 2, 0, 42},
Package(){0x0006ffff, 3, 0, 43},
Package(){0x0007ffff, 0, 0, 44},
Package(){0x0007ffff, 1, 0, 45},
Package(){0x0007ffff, 2, 0, 46},
Package(){0x0007ffff, 3, 0, 47},
Package(){0x0008ffff, 0, 0, 17},
Package(){0x0008ffff, 1, 0, 18},
Package(){0x0008ffff, 2, 0, 19},
Package(){0x0008ffff, 3, 0, 20},
Package(){0x0009ffff, 0, 0, 21},
Package(){0x0009ffff, 1, 0, 22},
Package(){0x0009ffff, 2, 0, 23},
Package(){0x0009ffff, 3, 0, 24},
Package(){0x000affff, 0, 0, 25},
Package(){0x000affff, 1, 0, 26},
Package(){0x000affff, 2, 0, 27},
Package(){0x000affff, 3, 0, 28},
Package(){0x000bffff, 0, 0, 29},
Package(){0x000bffff, 1, 0, 30},
Package(){0x000bffff, 2, 0, 31},
Package(){0x000bffff, 3, 0, 32},
Package(){0x000cffff, 0, 0, 33},
Package(){0x000cffff, 1, 0, 34},
Package(){0x000cffff, 2, 0, 35},
Package(){0x000cffff, 3, 0, 36},
Package(){0x000dffff, 0, 0, 37},
Package(){0x000dffff, 1, 0, 38},
Package(){0x000dffff, 2, 0, 39},
Package(){0x000dffff, 3, 0, 40},
Package(){0x000effff, 0, 0, 41},
Package(){0x000effff, 1, 0, 42},
Package(){0x000effff, 2, 0, 43},
Package(){0x000effff, 3, 0, 44},
Package(){0x000fffff, 0, 0, 45},
Package(){0x000fffff, 1, 0, 46},
Package(){0x000fffff, 2, 0, 47},
Package(){0x000fffff, 3, 0, 16},
Package(){0x0010ffff, 0, 0, 18},
Package(){0x0010ffff, 1, 0, 19},
Package(){0x0010ffff, 2, 0, 20},
Package(){0x0010ffff, 3, 0, 21},
Package(){0x0011ffff, 0, 0, 22},
Package(){0x0011ffff, 1, 0, 23},
Package(){0x0011ffff, 2, 0, 24},
Package(){0x0011ffff, 3, 0, 25},
Package(){0x0012ffff, 0, 0, 26},
Package(){0x0012ffff, 1, 0, 27},
Package(){0x0012ffff, 2, 0, 28},
Package(){0x0012ffff, 3, 0, 29},
Package(){0x0013ffff, 0, 0, 30},
Package(){0x0013ffff, 1, 0, 31},
Package(){0x0013ffff, 2, 0, 32},
Package(){0x0013ffff, 3, 0, 33},
Package(){0x0014ffff, 0, 0, 34},
Package(){0x0014ffff, 1, 0, 35},
Package(){0x0014ffff, 2, 0, 36},
Package(){0x0014ffff, 3, 0, 37},
Package(){0x0015ffff, 0, 0, 38},
Package(){0x0015ffff, 1, 0, 39},
Package(){0x0015ffff, 2, 0, 40},
Package(){0x0015ffff, 3, 0, 41},
Package(){0x0016ffff, 0, 0, 42},
Package(){0x0016ffff, 1, 0, 43},
Package(){0x0016ffff, 2, 0, 44},
Package(){0x0016ffff, 3, 0, 45},
Package(){0x0017ffff, 0, 0, 46},
Package(){0x0017ffff, 1, 0, 47},
Package(){0x0017ffff, 2, 0, 16},
Package(){0x0017ffff, 3, 0, 17},
Package(){0x0018ffff, 0, 0, 19},
Package(){0x0018ffff, 1, 0, 20},
Package(){0x0018ffff, 2, 0, 21},
Package(){0x0018ffff, 3, 0, 22},
Package(){0x0019ffff, 0, 0, 23},
Package(){0x0019ffff, 1, 0, 24},
Package(){0x0019ffff, 2, 0, 25},
Package(){0x0019ffff, 3, 0, 26},
Package(){0x001affff, 0, 0, 27},
Package(){0x001affff, 1, 0, 28},
Package(){0x001affff, 2, 0, 29},
Package(){0x001affff, 3, 0, 30},
Package(){0x001bffff, 0, 0, 31},
Package(){0x001bffff, 1, 0, 32},
Package(){0x001bffff, 2, 0, 33},
Package(){0x001bffff, 3, 0, 34},
Package(){0x001cffff, 0, 0, 35},
Package(){0x001cffff, 1, 0, 36},
Package(){0x001cffff, 2, 0, 37},
Package(){0x001cffff, 3, 0, 38},
Package(){0x001dffff, 0, 0, 39},
Package(){0x001dffff, 1, 0, 40},
Package(){0x001dffff, 2, 0, 41},
Package(){0x001dffff, 3, 0, 42},
Package(){0x001effff, 0, 0, 43},
Package(){0x001effff, 1, 0, 44},
Package(){0x001effff, 2, 0, 45},
Package(){0x001effff, 3, 0, 46},
Package(){0x001fffff, 0, 0, 47},
Package(){0x001fffff, 1, 0, 16},
Package(){0x001fffff, 2, 0, 17},
Package(){0x001fffff, 3, 0, 18},
})
        OperationRegion ( SEJ, SystemIO, 0xae08, 0x08 )
        Field ( SEJ, DWordAcc, NoLock, WriteAsZeros ) {
            B0EJ, 32,
            B0RM, 32,
        }
        Device ( S1 ) {
            Name ( _ADR, 0x00010000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000002, B0EJ )
            }
            Name ( _SUN, 1 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 1)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S2 ) {
            Name ( _ADR, 0x00020000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000004, B0EJ )
            }
            Name ( _SUN, 2 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 2)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S3 ) {
            Name ( _ADR, 0x00030000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000008, B0EJ )
            }
            Name ( _SUN, 3 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 3)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S4 ) {
            Name ( _ADR, 0x00040000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000010, B0EJ )
            }
            Name ( _SUN, 4 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 4)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S5 ) {
            Name ( _ADR, 0x00050000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000020, B0EJ )
            }
            Name ( _SUN, 5 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 5)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S6 ) {
            Name ( _ADR, 0x00060000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000040, B0EJ )
            }
            Name ( _SUN, 6 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 6)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S7 ) {
            Name ( _ADR, 0x00070000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000080, B0EJ )
            }
            Name ( _SUN, 7 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 7)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S8 ) {
            Name ( _ADR, 0x00080000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000100, B0EJ )
            }
            Name ( _SUN, 8 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 8)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S9 ) {
            Name ( _ADR, 0x00090000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000200, B0EJ )
            }
            Name ( _SUN, 9 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 9)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S10 ) {
            Name ( _ADR, 0x000a0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000400, B0EJ )
            }
            Name ( _SUN, 10 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 10)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S11 ) {
            Name ( _ADR, 0x000b0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00000800, B0EJ )
            }
            Name ( _SUN, 11 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 11)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S12 ) {
            Name ( _ADR, 0x000c0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00001000, B0EJ )
            }
            Name ( _SUN, 12 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 12)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S13 ) {
            Name ( _ADR, 0x000d0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00002000, B0EJ )
            }
            Name ( _SUN, 13 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 13)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S14 ) {
            Name ( _ADR, 0x000e0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00004000, B0EJ )
            }
            Name ( _SUN, 14 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 14)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S15 ) {
            Name ( _ADR, 0x000f0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00008000, B0EJ )
            }
            Name ( _SUN, 15 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 15)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S16 ) {
            Name ( _ADR, 0x00100000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00010000, B0EJ )
            }
            Name ( _SUN, 16 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 16)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S17 ) {
            Name ( _ADR, 0x00110000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00020000, B0EJ )
            }
            Name ( _SUN, 17 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 17)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S18 ) {
            Name ( _ADR, 0x00120000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00040000, B0EJ )
            }
            Name ( _SUN, 18 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 18)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S19 ) {
            Name ( _ADR, 0x00130000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00080000, B0EJ )
            }
            Name ( _SUN, 19 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 19)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S20 ) {
            Name ( _ADR, 0x00140000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00100000, B0EJ )
            }
            Name ( _SUN, 20 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 20)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S21 ) {
            Name ( _ADR, 0x00150000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00200000, B0EJ )
            }
            Name ( _SUN, 21 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 21)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S22 ) {
            Name ( _ADR, 0x00160000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00400000, B0EJ )
            }
            Name ( _SUN, 22 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 22)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S23 ) {
            Name ( _ADR, 0x00170000 )
            Method ( _EJ0,1 ) {
                Store ( 0x00800000, B0EJ )
            }
            Name ( _SUN, 23 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 23)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S24 ) {
            Name ( _ADR, 0x00180000 )
            Method ( _EJ0,1 ) {
                Store ( 0x01000000, B0EJ )
            }
            Name ( _SUN, 24 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 24)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S25 ) {
            Name ( _ADR, 0x00190000 )
            Method ( _EJ0,1 ) {
                Store ( 0x02000000, B0EJ )
            }
            Name ( _SUN, 25 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 25)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S26 ) {
            Name ( _ADR, 0x001a0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x04000000, B0EJ )
            }
            Name ( _SUN, 26 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 26)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S27 ) {
            Name ( _ADR, 0x001b0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x08000000, B0EJ )
            }
            Name ( _SUN, 27 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 27)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S28 ) {
            Name ( _ADR, 0x001c0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x10000000, B0EJ )
            }
            Name ( _SUN, 28 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 28)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S29 ) {
            Name ( _ADR, 0x001d0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x20000000, B0EJ )
            }
            Name ( _SUN, 29 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 29)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S30 ) {
            Name ( _ADR, 0x001e0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x40000000, B0EJ )
            }
            Name ( _SUN, 30 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 30)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
        Device ( S31 ) {
            Name ( _ADR, 0x001f0000 )
            Method ( _EJ0,1 ) {
                Store ( 0x80000000, B0EJ )
            }
            Name ( _SUN, 31 )
            Method ( _STA, 0 ) {
                If ( And(B0RM, ShiftLeft(1, 31)) ) {
                    Return ( 0xF )
                }
                Return ( 0x0 )
            }
        }
    }
    Scope ( \_GPE ) {
        OperationRegion ( PCST, SystemIO, 0xae00, 0x08 )
        Field ( PCST, DWordAcc, NoLock, WriteAsZeros ) {
            PCIU, 32,
            PCID, 32,
        }
        OperationRegion ( DG1, SystemIO, 0xb044, 0x04 )
        Field ( DG1, ByteAcc, NoLock, Preserve ) {
            DPT1, 8, DPT2, 8
        }
        Method ( _E01 ) {
            If ( And(PCIU, ShiftLeft(1, 1)) ) {
                Notify ( \_SB.PCI0.S1, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 1)) ) {
                Notify ( \_SB.PCI0.S1, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 2)) ) {
                Notify ( \_SB.PCI0.S2, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 2)) ) {
                Notify ( \_SB.PCI0.S2, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 3)) ) {
                Notify ( \_SB.PCI0.S3, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 3)) ) {
                Notify ( \_SB.PCI0.S3, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 4)) ) {
                Notify ( \_SB.PCI0.S4, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 4)) ) {
                Notify ( \_SB.PCI0.S4, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 5)) ) {
                Notify ( \_SB.PCI0.S5, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 5)) ) {
                Notify ( \_SB.PCI0.S5, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 6)) ) {
                Notify ( \_SB.PCI0.S6, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 6)) ) {
                Notify ( \_SB.PCI0.S6, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 7)) ) {
                Notify ( \_SB.PCI0.S7, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 7)) ) {
                Notify ( \_SB.PCI0.S7, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 8)) ) {
                Notify ( \_SB.PCI0.S8, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 8)) ) {
                Notify ( \_SB.PCI0.S8, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 9)) ) {
                Notify ( \_SB.PCI0.S9, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 9)) ) {
                Notify ( \_SB.PCI0.S9, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 10)) ) {
                Notify ( \_SB.PCI0.S10, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 10)) ) {
                Notify ( \_SB.PCI0.S10, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 11)) ) {
                Notify ( \_SB.PCI0.S11, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 11)) ) {
                Notify ( \_SB.PCI0.S11, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 12)) ) {
                Notify ( \_SB.PCI0.S12, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 12)) ) {
                Notify ( \_SB.PCI0.S12, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 13)) ) {
                Notify ( \_SB.PCI0.S13, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 13)) ) {
                Notify ( \_SB.PCI0.S13, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 14)) ) {
                Notify ( \_SB.PCI0.S14, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 14)) ) {
                Notify ( \_SB.PCI0.S14, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 15)) ) {
                Notify ( \_SB.PCI0.S15, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 15)) ) {
                Notify ( \_SB.PCI0.S15, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 16)) ) {
                Notify ( \_SB.PCI0.S16, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 16)) ) {
                Notify ( \_SB.PCI0.S16, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 17)) ) {
                Notify ( \_SB.PCI0.S17, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 17)) ) {
                Notify ( \_SB.PCI0.S17, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 18)) ) {
                Notify ( \_SB.PCI0.S18, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 18)) ) {
                Notify ( \_SB.PCI0.S18, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 19)) ) {
                Notify ( \_SB.PCI0.S19, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 19)) ) {
                Notify ( \_SB.PCI0.S19, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 20)) ) {
                Notify ( \_SB.PCI0.S20, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 20)) ) {
                Notify ( \_SB.PCI0.S20, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 21)) ) {
                Notify ( \_SB.PCI0.S21, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 21)) ) {
                Notify ( \_SB.PCI0.S21, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 22)) ) {
                Notify ( \_SB.PCI0.S22, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 22)) ) {
                Notify ( \_SB.PCI0.S22, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 23)) ) {
                Notify ( \_SB.PCI0.S23, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 23)) ) {
                Notify ( \_SB.PCI0.S23, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 24)) ) {
                Notify ( \_SB.PCI0.S24, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 24)) ) {
                Notify ( \_SB.PCI0.S24, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 25)) ) {
                Notify ( \_SB.PCI0.S25, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 25)) ) {
                Notify ( \_SB.PCI0.S25, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 26)) ) {
                Notify ( \_SB.PCI0.S26, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 26)) ) {
                Notify ( \_SB.PCI0.S26, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 27)) ) {
                Notify ( \_SB.PCI0.S27, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 27)) ) {
                Notify ( \_SB.PCI0.S27, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 28)) ) {
                Notify ( \_SB.PCI0.S28, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 28)) ) {
                Notify ( \_SB.PCI0.S28, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 29)) ) {
                Notify ( \_SB.PCI0.S29, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 29)) ) {
                Notify ( \_SB.PCI0.S29, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 30)) ) {
                Notify ( \_SB.PCI0.S30, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 30)) ) {
                Notify ( \_SB.PCI0.S30, 3 )
            }
            If ( And(PCIU, ShiftLeft(1, 31)) ) {
                Notify ( \_SB.PCI0.S31, 1 )
            }
            If ( And(PCID, ShiftLeft(1, 31)) ) {
                Notify ( \_SB.PCI0.S31, 3 )
            }
        }
    }
}
