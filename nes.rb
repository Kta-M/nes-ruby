# frozen_string_literal: true

require 'logger'
require './rom'
require './cpu'
require './cpu_bus'

# エミュレータークラス
class Nes
  def initialize(rom, logger)
    @logger = logger
    @bus = CpuBus.new(nil, nil, nil, nil, rom.prg_rom, @logger)
    @cpu = Cpu.new(@bus, @logger)
  end

  def run
    @logger.info('Start emulation')

    loop do
      @cpu.run
    end
  end
end
