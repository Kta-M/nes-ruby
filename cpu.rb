# frozen_string_literal: true

require 'logger'
require 'pry'
require './cpu_bus'
require './cpu_ops'
require './cpu_consts'

# CPUクラス
class Cpu
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

    reset
  end

  # 実行
  def run
    opcode = fetch
    param = Cpu::OP_PARAMS[opcode]
    if param.nil? || param[:op].nil?
      raise "Invalid opcode : #{format('0x%04X', opcode)}"
    end

    operand = fetch_operand(param[:mode])
    exec(param[:op], operand, param[:mode])

    output_op_log(opcode, operand, param)
    sleep(0.1)
  end

  # リセット
  def reset
    @registers[:PC] = @bus.read_word(0xFFFC)
  end

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  private

  # PCが指す値をフェッチしてPCを進める
  def fetch
    val = @bus.read(@registers[:PC])
    @registers[:PC] += 1
    val
  end

  # 2回フェッチしてwordとして返す
  def fetch_word
    fetch + (fetch << 8)
  end

  # オペランドを取得
  def fetch_operand(mode)
    send("fetch_operand_#{mode}")
  end

  # 一つの命令を実行
  def exec(opname, operand, mode)
    method = "exec_#{opname}"
    unless self.respond_to?(method, true)
      @logger.warn("Not Implemented Operation: #{opname}")
      return
    end
    send(method, operand, mode)
  end

  #----------------------------------------------------------------------------
  # [デバッグ用]実行した命令の情報をログに出す
  def output_op_log(opcode, operand, param)
    log = [
      "opcode: #{format('0x%04X', opcode)}",
      "opname: #{(param[:op] + '   ')[0, 4]}",
      "operand: #{format('0x%04X', operand.to_i)}",
      "mode: #{param[:mode]}"
    ].join(', ')
    @logger.debug(log)
  end
end
