# frozen_string_literal: true

require 'logger'

# ROMのクラス
class Rom
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  attr_reader :prg_rom
  attr_reader :chr_rom

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # 初期化
  def initialize(binary, logger)
    @logger = logger

    # iNesHeader取得
    header = INesHeader.new(binary, logger)

    # PRGROM取得
    @prg_rom = ProgramRom.new(
      binary,
      INesHeader::HEADER_SIZE,
      header.prg_rom_page_size,
      logger
    )

    # CHRROM取得
    @chr_rom = CharacterRom.new(
      binary,
      INesHeader::HEADER_SIZE + @prg_rom.rom_size,
      header.chr_rom_page_size,
      logger
    )
  end

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # iNesHeader
  class INesHeader
    # ヘッダサイズ
    HEADER_SIZE   = 0x0010
    # ヘッダのプレフィクス : "NES" followed by MS-DOS end-of-file
    HEADER_PREFIX = [0x4e, 0x45, 0x53, 0x1a].freeze

    attr_reader :header_prefix
    attr_reader :prg_rom_page_size
    attr_reader :chr_rom_page_size
    attr_reader :prg_ram_page_size

    def initialize(binary, logger)
      @logger = logger

      # HEADER確認
      @header_prefix = binary[0..3].each_char.map(&:ord)
      logger.info("HEADER_PREFIX : #{@header_prefix.map { |c| c.to_s(16) }}")
      raise 'Invalid Header' unless @header_prefix == HEADER_PREFIX

      # 各サイズ取得
      @prg_rom_page_size = binary[4].ord.to_i
      @chr_rom_page_size = binary[5].ord.to_i
      @prg_ram_page_size = binary[8].ord.to_i
    end
  end

  #----------------------------------------------------------------------------
  # プログラムROM
  class ProgramRom
    # プログラムROMのページサイズ
    PRG_ROM_UNIT = 0x4000

    attr_reader :rom_size
    attr_reader :rom_data

    def initialize(binary, data_pos, page_size, logger)
      @rom_size = PRG_ROM_UNIT * page_size
      @rom_data = binary[data_pos, @rom_size]
      logger.info("PRG_ROM_SIZE : #{@rom_size} bytes")
    end
  end

  #----------------------------------------------------------------------------
  # キャラクターROM
  class CharacterRom
    # キャラクタROMのページサイズ
    CHR_ROM_UNIT = 0x2000

    attr_reader :rom_size
    attr_reader :rom_data

    def initialize(binary, data_pos, page_size, logger)
      @rom_size = CHR_ROM_UNIT * page_size
      @rom_data = binary[data_pos, @rom_size]
      logger.info("CHR_ROM_SIZE : #{@rom_size} bytes")
    end
  end
end
