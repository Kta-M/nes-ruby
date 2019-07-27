# frozen_string_literal: true

require 'logger'
require 'pry'
require './rom'
require './cpu'
require './cpu_bus'
require './ppu'

# エミュレータークラス
class Nes
  def initialize(rom, logger)
    @logger = logger
    @ppu = Ppu.new(@logger)
    @bus = CpuBus.new(nil, @ppu, nil, nil, rom.prg_rom, @logger)
    @cpu = Cpu.new(@bus, @logger)
  end

  def run
    @logger.info('Start emulation')

    loop do
      @cpu.run
    end
  end
end
