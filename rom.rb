# frozen_string_literal: true

require 'logger'

# ROMのクラス
class Rom
  HEADER_SIZE   = 0x0010
  HEADER_PREFIX = [0x4e, 0x45, 0x53, 0x1a].freeze # "NES" followed by MS-DOS end-of-file
  PRG_ROM_UNIT  = 0x4000                   # 16KB
  CHR_ROM_UNIT  = 0x2000                   #  8KB

  attr_reader :prg_rom
  attr_reader :chr_rom

  def initialize(binary, logger)
    @logger = logger

    # HEADER確認
    header = binary[0..3].each_char(&:ord)
    logger.info("HEADER : #{header.map { |c| c.to_s(16) }}")
    raise 'Invalid Header' unless header == HEADER_PREFIX

    # PRGROM取得
    prg_rom_size = PRG_ROM_UNIT * binary[4].ord.to_i
    @prg_rom = binary[HEADER_SIZE, prg_rom_size]
    logger.info("PRG_ROM_SIZE : #{prg_rom_size} bytes")

    # CHRROM取得
    chr_rom_size = CHR_ROM_UNIT * binary[5].ord.to_i
    @prg_rom = binary[HEADER_SIZE + prg_rom_size, chr_rom_size]
    logger.info("CHR_ROM_SIZE : #{chr_rom_size} bytes")
  end
end
