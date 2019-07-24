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

  # rubocop:disable Metrics/CyclomaticComplexity
  def read(addr, _size)
    case addr
    when 0x0000...0x07FF
      @logger.debug('Not Implemented')
    when 0x0800...0x1FFF
      @logger.debug('Not Implemented')
    when 0x2000...0x2007
      @logger.debug('Not Implemented')
    when 0x2008...0x3FFF
      @logger.debug('Not Implemented')
    when 0x4000...0x401F
      @logger.debug('Not Implemented')
    when 0x4020...0x5FFF
      @logger.debug('Not Implemented')
    when 0x6000...0x7FFF
      @logger.debug('Not Implemented')
    when 0x8000...0xBFFF
      @logger.debug('Not Implemented')
    when 0xC000...0xFFFF
      @logger.debug('Not Implemented')
    else
      raise "Invalid Memory Access : #{addr}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/CyclomaticComplexity
  def write(addr, _data, _size)
    case addr
    when 0x0000...0x07FF
      @logger.debug('Not Implemented')
    when 0x0800...0x1FFF
      @logger.debug('Not Implemented')
    when 0x2000...0x2007
      @logger.debug('Not Implemented')
    when 0x2008...0x3FFF
      @logger.debug('Not Implemented')
    when 0x4000...0x401F
      @logger.debug('Not Implemented')
    when 0x4020...0x5FFF
      @logger.debug('Not Implemented')
    when 0x6000...0x7FFF
      @logger.debug('Not Implemented')
    when 0x8000...0xBFFF
      @logger.debug('Not Implemented')
    when 0xC000...0xFFFF
      @logger.debug('Not Implemented')
    else
      raise "Invalid Memory Access : #{addr}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
