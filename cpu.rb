# frozen_string_literal: true

require 'logger'
require './cpu_bus'

# CPUクラス
class Cpu
  # レジスターの初期値
  INIT_REGISTERS = {
    A:  0x00,             # アキュムレータ
    X:  0x00,             # インデックスレジスタ
    Y:  0x00,             # インデックスレジスタ
    P:  {                 # ステータスレジスタ
      negative:  false,   # ネガティブ     : 演算結果のbit7が1の時にセット
      overflow:  false,   # オーバーフロー : P演算結果がオーバーフローを起こした時にセット
      reserved:  true,    # 予約済み       : 常にセットされている
      break:     true,    # ブレークモード : BRK発生時にセット、IRQ発生時にクリア
      decimal:   false,   # デシマルモード : 0:デフォルト、1:BCDモード (NESでは未実装)
      interrupt: true,    # IRQ禁止        : 0:IRQ許可、1:IRQ禁止
      zero:      false,   # ゼロ           : 演算結果が0の時にセット
      carry:     false    # キャリー       : キャリー発生時にセット
    },
    SP: 0x01FD,           # スタックポインタ(実際は0x0100+8bit値)
    PC: 0x0000            # プログラムカウンタ
  }.freeze

  def initialize(bus, logger)
    @logger = logger
    @bus = bus
    @registers = {
      A:  0x00,             # アキュムレータ
      X:  0x00,             # インデックスレジスタ
      Y:  0x00,             # インデックスレジスタ
      P:  {                 # ステータスレジスタ
        negative:  false,   # ネガティブ     : 演算結果のbit7が1の時にセット
        overflow:  false,   # オーバーフロー : P演算結果がオーバーフローを起こした時にセット
        reserved:  true,    # 予約済み       : 常にセットされている
        break:     true,    # ブレークモード : BRK発生時にセット、IRQ発生時にクリア
        decimal:   false,   # デシマルモード : 0:デフォルト、1:BCDモード (NESでは未実装)
        interrupt: true,    # IRQ禁止        : 0:IRQ許可、1:IRQ禁止
        zero:      false,   # ゼロ           : 演算結果が0の時にセット
        carry:     false    # キャリー       : キャリー発生時にセット
      },
      SP: 0x01FD,           # スタックポインタ(実際は0x0100+8bit値)
      PC: 0x0000            # プログラムカウンタ
    }

    self.reset
  end

  def read(addr)
    @bus.read(addr, 1)
  end

  def read_word(addr)
    @bus.read(addr, 2)
  end

  def write(addr, data)
    @bus.write(addr, data, 1)
  end

  def write_word(addr, data)
    @bus.write(addr, data, 2)
  end

  def fetch
    opecode = self.read(@registers[:PC])
    @registers[:PC] += 1
    opecode
  end

  # 実行
  def run
    opecode = self.fetch
    @logger.info("opecode: #{opecode}")
  end

  # リセット
  def reset
    @registers[:PC] = self.read_word(0xFFFC)
  end
end
