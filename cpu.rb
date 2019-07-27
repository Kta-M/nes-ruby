# frozen_string_literal: true

require 'logger'
require 'pry'
require './cpu_bus'
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

    @logger.debug("opcode: #{format('0x%04X', opcode)}, operand: #{operand}, param: #{param}")
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

  #----------------------------------------------------------------------------
  # オペランドを取得
  def fetch_operand(mode)
    send("fetch_operand_#{mode}")
  end

  # impl
  # レジスタを操作するため、アドレス操作無し
  def fetch_operand_implied
    nil
  end

  # A
  # Aレジスタを操作するため、アドレス操作無し
  def fetch_operand_accumulator
    nil
  end

  # #
  # オペコードが格納されていた次の番地に格納されている値をデータとして扱う
  def fetch_operand_immediate
    fetch
  end

  # zpg
  # 0x00を上位アドレス、PCに格納された値を下位アドレスとした番地を演算対象とする
  def fetch_operand_zero_page
    fetch
  end

  # zpg,X
  # 0x00を上位アドレス、PCに格納された値にXレジスタを加算した値を下位アドレスとした番地を
  # 演算対象とする
  def fetch_operand_zero_page_x
    (fetch + @registers[:X]) & 0xFF
  end

  # zpg,Y
  # 0x00を上位アドレス、PCに格納された値にYレジスタを加算した値を下位アドレスとした番地を
  # 演算対象とする
  def fetch_operand_zero_page_y
    (fetch + @registers[:Y]) & 0xFF
  end

  # abs
  # PCに格納された値を下位アドレス、 次のPCに格納された値を上位アドレスとした番地を
  # 演算対象とする
  def fetch_operand_absolute
    fetch_word
  end

  # abs,X
  # absで得られる値にXレジスタを加算した番地を演算対象とする
  def fetch_operand_absolute_x
    (fetch_word + @registers[:X]) & 0xFFFF
  end

  # abs,Y
  # absで得られる値にYレジスタを加算した番地を演算対象とする
  def fetch_operand_absolute_y
    (fetch_word + @registers[:Y]) & 0xFFFF
  end

  # rel
  # PCに格納された値とその次の番地の値を加算した番地を演算対象とする
  def fetch_operand_relative
    base = fetch
    # オフセット値はsigned charとして扱う
    offset = base < 0x80 ? @registers[:PC] : @registers[:PC] - 256
    base + offset
  end

  # X,Ind
  # 0x00を上位アドレス、PCに格納された値を下位アドレスとした番地にレジスタXの値を加算、
  # その番地の値を下位アドレス、その次の番地の値を上位アドレスとした番地を演算対象とする
  def fetch_operand_pre_indexed_indirect
    base_addr = (fetch + @registers[:X]) & 0xFF
    addr = @bus.read(base_addr) +
           ((@bus.read(base_addr + 1) & 0xFF) << 8)
    addr & 0xFFFF
  end

  # Ind,Y
  # 0x00を上位アドレス、PCに格納された値を下位アドレスとした番地の値を下位アドレス、
  # その次の番地の値を上位アドレスとした番地にレジスタYを加算した番地を演算対象とする
  def fetch_operand_post_indexed_indirect
    base_addr = fetch
    addr = @bus.read(base_addr) +
           ((@bus.read(base_addr + 1) & 0xFF) << 8) +
           @registers[:Y]
    addr & 0xFFFF
  end

  # Ind
  # absで得られる番地に格納されている値を下位アドレス、
  # その次の番地に格納されている値を上位アドレスとした番地を演算対象とする
  # 次の番地を得るためのインクリメントでの下位バイトからのキャリーは無視する
  def fetch_operand_indirect_absolute
    base_addr = fetch_word
    addr = @bus.read(base_addr) +
           ((@bus.read((base_addr & 0xFF00) | ((base_addr + 1) & 0xFF)) & 0xFF) << 8)
    addr & 0xFFFF
  end

  #----------------------------------------------------------------------------
  # 一つの命令を実行
  def exec(opname, operand, mode)
    method = "exec_#{opname}"
    unless self.respond_to?(method)
      @logger.warn("Not Implemented Operation: #{opname}")
      return
    end
    send(method, oprand, mode)
  end
end
