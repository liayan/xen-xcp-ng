ENTRY(start_pa)
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
PHDRS
{
  text PT_LOAD ;
  note PT_NOTE ;
}
SECTIONS
{
  . = (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)));
  __image_base__ = .;
  start_pa = ABSOLUTE(start - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))));
  . = (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) + 0x200000;
  _start = .;
  .text : AT(ADDR(".text") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
        _stext = .;
       *(.text)
       *(.text.__x86_indirect_thunk_*)
       *(.text.page_aligned)
       . = ALIGN((1 << 12));
       _stextentry = .;
       *(.text.entry)
       . = ALIGN((1 << 12));
       _etextentry = .;
       *(.text.cold)
       *(.text.unlikely)
       *(.fixup)
       *(.text.kexec)
       *(.gnu.warning)
       _etext = .;
  } :text = 0x9090
  . = ALIGN((2 << 20));
  __2M_text_end = .;
  __2M_rodata_start = .;
  .rodata : AT(ADDR(".rodata") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       _srodata = .;
       __start_bug_frames = .;
       *(.bug_frames.0)
       __stop_bug_frames_0 = .;
       *(.bug_frames.1)
       __stop_bug_frames_1 = .;
       *(.bug_frames.2)
       __stop_bug_frames_2 = .;
       *(.bug_frames.3)
       __stop_bug_frames_3 = .;
       *(.rodata)
       *(.rodata.*)
       *(.data.rel.ro)
       *(.data.rel.ro.*)
       . = ALIGN(8);
       __start___ex_table = .;
       *(.ex_table)
       __stop___ex_table = .;
       __start___pre_ex_table = .;
       *(.ex_table.pre)
       __stop___pre_ex_table = .;
       . = ALIGN((1 << 3));
       __param_start = .;
       *(.data.param)
       __param_end = .;
  } :text
  .note.Xen : AT(ADDR(".note.Xen") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
      *(.note.Xen)
  } :note :text
  .note.gnu.build-id : AT(ADDR(".note.gnu.build-id") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       __note_gnu_build_id_start = .;
       *(.note.gnu.build-id)
       __note_gnu_build_id_end = .;
  } :note :text
  . = ALIGN(4);
  .reloc : AT(ADDR(".reloc") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
    *(.reloc)
  } :text
  _erodata = .;
  . = ALIGN((2 << 20));
  __2M_rodata_end = .;
  __2M_init_start = .;
  . = ALIGN((1 << 12));
  __init_begin = .;
  .init.text : AT(ADDR(".init.text") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       _sinittext = .;
       *(.init.text)
       *(.altinstr_replacement)
       _einittext = .;
  } :text
  .init.data : AT(ADDR(".init.data") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       *(.init.rodata)
       *(.init.rodata.*)
       . = ALIGN((1 << 3));
       __setup_start = .;
       *(.init.setup)
       __setup_end = .;
       __initcall_start = .;
       *(.initcallpresmp.init)
       __presmp_initcall_end = .;
       *(.initcall1.init)
       __initcall_end = .;
       *(.init.data)
       *(.init.data.rel)
       *(.init.data.rel.*)
       . = ALIGN(4);
       __trampoline_rel_start = .;
       *(.trampoline_rel)
       __trampoline_rel_stop = .;
       __trampoline_seg_start = .;
       *(.trampoline_seg)
       __trampoline_seg_stop = .;
       . = ALIGN(8);
        __alt_instructions = .;
        *(.altinstructions)
        __alt_instructions_end = .;
       . = ALIGN(8);
       __ctors_start = .;
       *(.ctors)
       *(.init_array)
       *(SORT(.init_array.*))
       __ctors_end = .;
  } :text
  . = ALIGN((2 << 20));
  __init_end = .;
  __2M_init_end = .;
  __2M_rwdata_start = .;
  . = ALIGN((1 << (7)));
  .data.read_mostly : AT(ADDR(".data.read_mostly") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       *(.data.read_mostly)
       . = ALIGN(8);
       __start_schedulers_array = .;
       *(.data.schedulers)
       __end_schedulers_array = .;
  } :text
  .data : AT(ADDR(".data") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       *(.data.page_aligned)
       *(.data)
       *(.data.rel)
       *(.data.rel.*)
       CONSTRUCTORS
  } :text
  .bss : AT(ADDR(".bss") - (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)))) {
       __bss_start = .;
       *(.bss.stack_aligned)
       *(.bss.page_aligned*)
       . = ALIGN((1 << 12));
       __per_cpu_start = .;
       *(.bss.percpu.page_aligned)
       *(.bss.percpu)
       . = ALIGN((1 << (7)));
       *(.bss.percpu.read_mostly)
       . = ALIGN((1 << (7)));
       __per_cpu_data_end = .;
       *(.bss)
       . = ALIGN((1 << 3));
       __bss_end = .;
  } :text
  _end = . ;
  . = ALIGN((2 << 20));
  __2M_rwdata_end = .;
  /DISCARD/ : {
       *(.exit.text)
       *(.exit.data)
       *(.exitcall.exit)
       *(.discard)
       *(.discard.*)
       *(.eh_frame)
  }
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .stab.excl 0 : { *(.stab.excl) }
  .stab.exclstr 0 : { *(.stab.exclstr) }
  .stab.index 0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment 0 : { *(.comment) }
}
ASSERT(__image_base__ > (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) |
       __2M_rwdata_end <= ((((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) + (1 << 30)) - 32 * (1 << 12),
       "Xen image overlaps stubs area")
ASSERT((((__2M_text_end) & (((2 << 20)) - 1)) == 0), "__2M_text_end misaligned")
ASSERT((((__2M_rodata_start) & (((2 << 20)) - 1)) == 0), "__2M_rodata_start misaligned")
ASSERT((((__2M_rodata_end) & (((2 << 20)) - 1)) == 0), "__2M_rodata_end misaligned")
ASSERT((((__2M_init_start) & (((2 << 20)) - 1)) == 0), "__2M_init_start misaligned")
ASSERT((((__2M_init_end) & (((2 << 20)) - 1)) == 0), "__2M_init_end misaligned")
ASSERT((((__2M_rwdata_start) & (((2 << 20)) - 1)) == 0), "__2M_rwdata_start misaligned")
ASSERT((((__2M_rwdata_end) & (((2 << 20)) - 1)) == 0), "__2M_rwdata_end misaligned")
ASSERT((((cpu0_stack) & ((((1 << 12) << 3)) - 1)) == 0), "cpu0_stack misaligned")
ASSERT((((__init_begin) & (((1 << 12)) - 1)) == 0), "__init_begin misaligned")
ASSERT((((__init_end) & (((1 << 12)) - 1)) == 0), "__init_end misaligned")
ASSERT((((trampoline_start) & ((4) - 1)) == 0), "trampoline_start misaligned")
ASSERT((((trampoline_end) & ((4) - 1)) == 0), "trampoline_end misaligned")
ASSERT((((__bss_start) & ((8) - 1)) == 0), "__bss_start misaligned")
ASSERT((((__bss_end) & ((8) - 1)) == 0), "__bss_end misaligned")
ASSERT((trampoline_end - trampoline_start) < ((64 << 10) - (1 << 12)) - (2 * (1 << 12)),
    "not enough room for trampoline and mbi data")
ASSERT((wakeup_stack - wakeup_stack_start) >= 3072,
    "wakeup stack too small")
