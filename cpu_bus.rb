# frozen_string_literal: true

require 'logger'

# CPUバスクラス
class CpuBus
  # rubocop:disable Metrics/ParameterLists
  def initialize(wram, ppu_reg, apu_io, pad, prg_rom, logger)
    @logger = logger
    @wram    = wram
    @ppu_reg = ppu_reg
    @apu_io  = apu_io
    @pad     = pad
    @prg_rom = prg_rom
  end
  # rubocop:enable Metrics/ParameterLists

  def read(addr)
    __read(addr)
  end

  def read_word(addr)
    __read(addr) + (__read(addr + 1) << 8)
  end

  def write(addr)
    __write(addr, data)
  end

  def write_word(addr, data)
    __write(addr, data & 0x0F)
    __write(addr + 1, (data & 0xF0) >> 8)
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity
  def __read(addr)
    case addr
    when 0x0000..0x07FF
      0
    when 0x0800..0x1FFF
      0
    when 0x2000..0x2007
      0
    when 0x2008..0x3FFF
      0
    when 0x4000..0x401F
      0
    when 0x4020..0x5FFF
      0
    when 0x6000..0x7FFF
      0
    when 0x8000..0xBFFF, 0xC000..0xFFFF
      @prg_rom.read(addr - 0x8000)
    else
      raise "Invalid Memory Access : #{'0x%08X' % addr}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/CyclomaticComplexity
  def __write(addr, data)
    case addr
    when 0x0000..0x07FF
      @logger.debug('Not Implemented')
    when 0x0800..0x1FFF
      @logger.debug('Not Implemented')
    when 0x2000..0x2007
      @logger.debug('Not Implemented')
    when 0x2008..0x3FFF
      @logger.debug('Not Implemented')
    when 0x4000..0x401F
      @logger.debug('Not Implemented')
    when 0x4020..0x5FFF
      @logger.debug('Not Implemented')
    when 0x6000..0x7FFF
      @logger.debug('Not Implemented')
    when 0x8000..0xBFFF, 0xC000..0xFFFF
      raise "Invalid To Write : #{'0x%08X' % addr}"
    else
      raise "Invalid Memory Access : #{'0x%08X' % addr}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
