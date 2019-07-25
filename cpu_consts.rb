# frozen_string_literal: true

# CPUクラスの定数のみ定義
# rubocop:disable Metrics/ClassLength
class Cpu
  # 命令セット
  OP_PARAMS = [
    # 0x00
    { op: "BRK",  mode: "implied",               cycle: 7 },
    { op: "ORA",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SLO",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 3 },
    { op: "ORA",  mode: "zero_page",             cycle: 3 },
    { op: "ASL",  mode: "zero_page",             cycle: 5 },
    { op: "SLO",  mode: "zero_page",             cycle: 5 },
    { op: "PHP",  mode: "implied",               cycle: 3 },
    { op: "ORA",  mode: "immediate",             cycle: 2 },
    { op: "ASL",  mode: "accumulator",           cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "ORA",  mode: "absolute",              cycle: 4 },
    { op: "ASL",  mode: "absolute",              cycle: 6 },
    { op: "SLO",  mode: "absolute",              cycle: 6 },
    # 0x10
    { op: "BPL",  mode: "relative",              cycle: 2 },
    { op: "ORA",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SLO",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "ORA",  mode: "zero_page_x",           cycle: 4 },
    { op: "ASL",  mode: "zero_page_x",           cycle: 6 },
    { op: "SLO",  mode: "zero_page_x",           cycle: 6 },
    { op: "CLC",  mode: "implied",               cycle: 2 },
    { op: "ORA",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SLO",  mode: "absolute_y",            cycle: 7 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "ORA",  mode: "absolute_x",            cycle: 4 },
    { op: "ASL",  mode: "absolute_x",            cycle: 6 },
    { op: "SLO",  mode: "absolute_x",            cycle: 7 },
    # 0x20
    { op: "JSR",  mode: "absolute",              cycle: 6 },
    { op: "AND",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RLA",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "BIT",  mode: "zero_page",             cycle: 3 },
    { op: "AND",  mode: "zero_page",             cycle: 3 },
    { op: "ROL",  mode: "zero_page",             cycle: 5 },
    { op: "RLA",  mode: "zero_page",             cycle: 5 },
    { op: "PLP",  mode: "implied",               cycle: 4 },
    { op: "AND",  mode: "immediate",             cycle: 2 },
    { op: "ROL",  mode: "accumulator",           cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "BIT",  mode: "absolute",              cycle: 4 },
    { op: "AND",  mode: "absolute",              cycle: 4 },
    { op: "ROL",  mode: "absolute",              cycle: 6 },
    { op: "RLA",  mode: "absolute",              cycle: 6 },
    # 0x30
    { op: "BMI",  mode: "relative",              cycle: 2 },
    { op: "AND",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RLA",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "AND",  mode: "zero_page_x",           cycle: 4 },
    { op: "ROL",  mode: "zero_page_x",           cycle: 6 },
    { op: "RLA",  mode: "zero_page_x",           cycle: 6 },
    { op: "SEC",  mode: "implied",               cycle: 2 },
    { op: "AND",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RLA",  mode: "absolute_y",            cycle: 7 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "AND",  mode: "absolute_x",            cycle: 4 },
    { op: "ROL",  mode: "absolute_x",            cycle: 6 },
    { op: "RLA",  mode: "absolute_x",            cycle: 7 },
    # 0x40
    { op: "RTI",  mode: "implied",               cycle: 6 },
    { op: "EOR",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SRE",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 3 },
    { op: "EOR",  mode: "zero_page",             cycle: 3 },
    { op: "LSR",  mode: "zero_page",             cycle: 5 },
    { op: "SRE",  mode: "zero_page",             cycle: 5 },
    { op: "PHA",  mode: "implied",               cycle: 3 },
    { op: "EOR",  mode: "immediate",             cycle: 2 },
    { op: "LSR",  mode: "accumulator",           cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "JMP",  mode: "absolute",              cycle: 3 },
    { op: "EOR",  mode: "absolute",              cycle: 4 },
    { op: "LSR",  mode: "absolute",              cycle: 6 },
    { op: "SRE",  mode: "absolute",              cycle: 6 },
    # 0x50
    { op: "BVC",  mode: "relative",              cycle: 2 },
    { op: "EOR",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SRE",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "EOR",  mode: "zero_page_x",           cycle: 4 },
    { op: "LSR",  mode: "zero_page_x",           cycle: 6 },
    { op: "SRE",  mode: "zero_page_x",           cycle: 6 },
    { op: "CLI",  mode: "implied",               cycle: 2 },
    { op: "EOR",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SRE",  mode: "absolute_y",            cycle: 7 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "EOR",  mode: "absolute_x",            cycle: 4 },
    { op: "LSR",  mode: "absolute_x",            cycle: 6 },
    { op: "SRE",  mode: "absolute_x",            cycle: 7 },
    # 0x60
    { op: "RTS",  mode: "implied",               cycle: 6 },
    { op: "ADC",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RRA",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 3 },
    { op: "ADC",  mode: "zero_page",             cycle: 3 },
    { op: "ROR",  mode: "zero_page",             cycle: 5 },
    { op: "RRA",  mode: "zero_page",             cycle: 5 },
    { op: "PLA",  mode: "implied",               cycle: 4 },
    { op: "ADC",  mode: "immediate",             cycle: 2 },
    { op: "ROR",  mode: "accumulator",           cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "JMP",  mode: "indirect_absolute",     cycle: 5 },
    { op: "ADC",  mode: "absolute",              cycle: 4 },
    { op: "ROR",  mode: "absolute",              cycle: 6 },
    { op: "RRA",  mode: "absolute",              cycle: 6 },
    # 0x70
    { op: "BVS",  mode: "relative",              cycle: 2 },
    { op: "ADC",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RRA",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "ADC",  mode: "zero_page_x",           cycle: 4 },
    { op: "ROR",  mode: "zero_page_x",           cycle: 6 },
    { op: "RRA",  mode: "zero_page_x",           cycle: 6 },
    { op: "SEI",  mode: "implied",               cycle: 2 },
    { op: "ADC",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "RRA",  mode: "absolute_y",            cycle: 7 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "ADC",  mode: "absolute_x",            cycle: 4 },
    { op: "ROR",  mode: "absolute_x",            cycle: 6 },
    { op: "RRA",  mode: "absolute_x",            cycle: 7 },
    # 0x80
    { op: "NOPD", mode: "implied",               cycle: 2 },
    { op: "STA",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOPD", mode: "implied",               cycle: 2 },
    { op: "SAX",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "STY",  mode: "zero_page",             cycle: 3 },
    { op: "STA",  mode: "zero_page",             cycle: 3 },
    { op: "STX",  mode: "zero_page",             cycle: 3 },
    { op: "SAX",  mode: "zero_page",             cycle: 3 },
    { op: "DEY",  mode: "implied",               cycle: 2 },
    { op: "NOPD", mode: "implied",               cycle: 2 },
    { op: "TXA",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "STY",  mode: "absolute",              cycle: 4 },
    { op: "STA",  mode: "absolute",              cycle: 4 },
    { op: "STX",  mode: "absolute",              cycle: 4 },
    { op: "SAX",  mode: "absolute",              cycle: 4 },
    # 0x90
    { op: "BCC",  mode: "relative",              cycle: 2 },
    { op: "STA",  mode: "post_indexed_indirect", cycle: 6 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "STY",  mode: "zero_page_x",           cycle: 4 },
    { op: "STA",  mode: "zero_page_x",           cycle: 4 },
    { op: "STX",  mode: "zero_page_y",           cycle: 4 },
    { op: "SAX",  mode: "zero_page_y",           cycle: 4 },
    { op: "TYA",  mode: "implied",               cycle: 2 },
    { op: "STA",  mode: "absolute_y",            cycle: 4 },
    { op: "TXS",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "STA",  mode: "absolute_x",            cycle: 4 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: nil,    mode: nil,                     cycle: 0 },
    # 0xA0
    { op: "LDY",  mode: "immediate",             cycle: 2 },
    { op: "LDA",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "LDX",  mode: "immediate",             cycle: 2 },
    { op: "LAX",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "LDY",  mode: "zero_page",             cycle: 3 },
    { op: "LDA",  mode: "zero_page",             cycle: 3 },
    { op: "LDX",  mode: "zero_page",             cycle: 3 },
    { op: "LAX",  mode: "zero_page",             cycle: 3 },
    { op: "TAY",  mode: "implied",               cycle: 2 },
    { op: "LDA",  mode: "immediate",             cycle: 2 },
    { op: "TAX",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "LDY",  mode: "absolute",              cycle: 4 },
    { op: "LDA",  mode: "absolute",              cycle: 4 },
    { op: "LDX",  mode: "absolute",              cycle: 4 },
    { op: "LAX",  mode: "absolute",              cycle: 4 },
    # 0xB0
    { op: "BCS",  mode: "relative",              cycle: 2 },
    { op: "LDA",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "LAX",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "LDY",  mode: "zero_page_x",           cycle: 4 },
    { op: "LDA",  mode: "zero_page_x",           cycle: 4 },
    { op: "LDX",  mode: "zero_page_y",           cycle: 4 },
    { op: "LAX",  mode: "zero_page_y",           cycle: 4 },
    { op: "CLV",  mode: "implied",               cycle: 2 },
    { op: "LDA",  mode: "absolute_y",            cycle: 4 },
    { op: "TSX",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "LDY",  mode: "absolute_x",            cycle: 4 },
    { op: "LDA",  mode: "absolute_x",            cycle: 4 },
    { op: "LDX",  mode: "absolute_y",            cycle: 4 },
    { op: "LAX",  mode: "absolute_y",            cycle: 4 },
    # 0xC0
    { op: "CPY",  mode: "immediate",             cycle: 2 },
    { op: "CMP",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOPD", mode: "implied",               cycle: 2 },
    { op: "DCP",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "CPY",  mode: "zero_page",             cycle: 3 },
    { op: "CMP",  mode: "zero_page",             cycle: 3 },
    { op: "DEC",  mode: "zero_page",             cycle: 5 },
    { op: "DCP",  mode: "zero_page",             cycle: 5 },
    { op: "INY",  mode: "implied",               cycle: 2 },
    { op: "CMP",  mode: "immediate",             cycle: 2 },
    { op: "DEX",  mode: "implied",               cycle: 2 },
    { op: nil,    mode: nil,                     cycle: 0 },
    { op: "CPY",  mode: "absolute",              cycle: 4 },
    { op: "CMP",  mode: "absolute",              cycle: 4 },
    { op: "DEC",  mode: "absolute",              cycle: 6 },
    { op: "DCP",  mode: "absolute",              cycle: 6 },
    # 0xD0
    { op: "BNE",  mode: "relative",              cycle: 2 },
    { op: "CMP",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "DCP",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "CMP",  mode: "zero_page_x",           cycle: 4 },
    { op: "DEC",  mode: "zero_page_x",           cycle: 6 },
    { op: "DCP",  mode: "zero_page_x",           cycle: 6 },
    { op: "CLD",  mode: "implied",               cycle: 2 },
    { op: "CMP",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "DCP",  mode: "absolute_y",            cycle: 2 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "CMP",  mode: "absolute_x",            cycle: 4 },
    { op: "DEC",  mode: "absolute_x",            cycle: 7 },
    { op: "DCP",  mode: "absolute_x",            cycle: 7 },
    # 0xE0
    { op: "CPX",  mode: "immediate",             cycle: 2 },
    { op: "SBC",  mode: "pre_indexed_indirect",  cycle: 6 },
    { op: "NOPD", mode: "implied",               cycle: 3 },
    { op: "ISB",  mode: "pre_indexed_indirect",  cycle: 8 },
    { op: "CPX",  mode: "zero_page",             cycle: 3 },
    { op: "SBC",  mode: "zero_page",             cycle: 3 },
    { op: "INC",  mode: "zero_page",             cycle: 5 },
    { op: "ISB",  mode: "zero_page",             cycle: 5 },
    { op: "INX",  mode: "implied",               cycle: 2 },
    { op: "SBC",  mode: "immediate",             cycle: 2 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "SBC",  mode: "immediate",             cycle: 2 },
    { op: "CPX",  mode: "absolute",              cycle: 4 },
    { op: "SBC",  mode: "absolute",              cycle: 4 },
    { op: "INC",  mode: "absolute",              cycle: 6 },
    { op: "ISB",  mode: "absolute",              cycle: 6 },
    # 0xF0
    { op: "BEQ",  mode: "relative",              cycle: 2 },
    { op: "SBC",  mode: "post_indexed_indirect", cycle: 5 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "ISB",  mode: "post_indexed_indirect", cycle: 8 },
    { op: "NOPD", mode: "implied",               cycle: 4 },
    { op: "SBC",  mode: "zero_page_x",           cycle: 4 },
    { op: "INC",  mode: "zero_page_x",           cycle: 6 },
    { op: "ISB",  mode: "zero_page_x",           cycle: 6 },
    { op: "SED",  mode: "implied",               cycle: 2 },
    { op: "SBC",  mode: "absolute_y",            cycle: 4 },
    { op: "NOP",  mode: "implied",               cycle: 2 },
    { op: "ISB",  mode: "absolute_y",            cycle: 2 },
    { op: "NOPI", mode: "implied",               cycle: 4 },
    { op: "SBC",  mode: "absolute_x",            cycle: 4 },
    { op: "INC",  mode: "absolute_x",            cycle: 7 },
    { op: "ISB",  mode: "absolute_x",            cycle: 7 }
  ].freeze
end
# rubocop:enable Metrics/ClassLength
