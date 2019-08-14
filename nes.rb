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
    @ppu = Ppu.new(rom.chr_rom, @logger)
    @bus = CpuBus.new(nil, @ppu, nil, nil, rom.prg_rom, @logger)
    @cpu = Cpu.new(@bus, @logger)
  end

  def run
    @logger.info('Start emulation')

    loop do
      cycle = @cpu.run
      # PPUはCPUの3倍の速度で動作する
      @ppu.run(cycle * 3)

      # 描画準備ができていたら画面を更新
      if @ppu.ready?
        # @renderer.render(@ppu.bg_data)
      end
    end
  end
end
