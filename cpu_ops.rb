# frozen_string_literal: true

require 'logger'
require 'pry'

# CPUクラスの命令セットを定義
# rubocop:disable Metrics/ClassLength
class Cpu
  private

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # オペランドのフェッチ

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

  # rubocop:disable Naming/MethodName
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # 命令

  #----------------------------------------------------------------------------
  # 演算
  # ADC (Add M to A with C)  A + M + C -> A
  # SBC (Subtract M from A with C)  A - M - not C -> A

  #----------------------------------------------------------------------------
  # 論理演算
  # AND ("AND" M with A)  A and M -> A
  # ORA ("OR" M with A)  A or M -> A
  # EOR ("Exclusive-OR" M with A)  A eor M -> A

  #----------------------------------------------------------------------------
  # シフト、ローテーション
  # ASL (Arithmetic shift left one bit)
  # Aを左シフト、ビット0には0
  # C <- Aのビット7
  # LSR (Logical shift right one bit)
  # Aを右シフト、ビット7には0
  # Aのビット0 -> C
  # ROL (Rotate left one bit)
  # Aを左シフト、ビット0にはC
  # C <- Aのビット7
  # ROR (Rotate right one bit)
  # Aを右シフト、ビット7にはC
  # Aのビット0 -> C

  #----------------------------------------------------------------------------
  # 条件分岐
  # BCC (Branch on C clear)
  # Cフラグがクリアされていれば分岐します。
  # BCS (Branch on C set)
  # Cフラグがセットされていれば分岐します。
  # BEQ (Branch on Z set (result equal))
  # Zフラグがセットされていれば分岐します。
  # BNE (Branch on Z clear (result not equal))
  # Zフラグがクリアされていれば分岐します。
  # BVC (Branch on V clear)
  # Vフラグがクリアされていれば分岐します。
  # BVS (Branch on V set)
  # Vフラグがセットされていれば分岐します。
  # BPL (Branch on N clear (result plus))
  # Nフラグがクリアされていれば分岐します。
  # BMI (Branch on N set (result minus))
  # Nフラグがセットされていれば分岐します。

  #----------------------------------------------------------------------------
  # ビット検査
  # BIT (Test Bits in M with A)
  # メモリのデータをAでテストします。
  # A and M の結果でZフラグをセットし、Mのビット7をNへ、ビット6をVへ転送します。
  # flags: N V Z

  #----------------------------------------------------------------------------
  # ジャンプ
  # JMP (Jump to new location)
  # ADDR -> PC
  # flags: none
  # JSR (Jump to new location saving return address)
  # ADDR -> PC
  # サブルーチンへジャンプします。
  # まずジャンプ先のアドレスをアドレス指定によって取得した後、 PCを上位バイト、下位バイトの順にスタックへプッシュします。 このときのPCはトラップの項にもあるようにJSRの最後のバイトアドレスです。 最後にジャンプ先へジャンプします。
  # flags: none
  # RTS (Return from Subroutine)
  # サブルーチンから復帰します。
  # 復帰アドレスをスタックから、下位バイト、 上位バイトの順にポップしたのちインクリメントします。
  # flags: none

  #----------------------------------------------------------------------------
  # 割り込み
  # BRK (Force Break)
  # ソフトウエア割り込みを発生します。
  # 動作は割り込みの項を参照。
  # flags: B I
  # RTI (Return from Interrupt)
  # 割り込みから復帰します。
  # スタックから、ステータスレジスタ、PCの下位バイト、上位バイトの順にポップします。
  # flags: all

  #----------------------------------------------------------------------------
  # 比較
  # CMP (Compare M and A)  A - M
  # CPX (Compare M and X)  X - M
  # CPY (Compare M and Y)  Y - M

  #----------------------------------------------------------------------------
  # インクリメント、デクリメント
  # INC (Increment M by one)  M + 1 -> M
  # DEC (Decrement M by one)  M - 1 -> M

  # INX (Increment X by one)  X + 1 -> X
  def exec_INX(_operand, _mode)
    __exec_IN_(:X)
  end

  # DEX (Decrement X by one)  X - 1 -> X
  def exec_DEX(_operand, _mode)
    __exec_DE_(:X)
  end

  # INY (Increment Y by one)  Y + 1 -> Y
  def exec_INY(_operand, _mode)
    __exec_IN_(:Y)
  end

  # DEY (Decrement Y by one)  Y - 1 -> Y
  def exec_DEY(_operand, _mode)
    __exec_DE_(:Y)
  end

  def __exec_IN_(type)
    @registers[type] = (@registers[type] + 1) & 0xFF;
    update_status_register_ng(@registers[type])
  end

  def __exec_DE_(type)
    @registers[type] = (@registers[type] - 1) & 0xFF;
    update_status_register_ng(@registers[type])
  end

  #----------------------------------------------------------------------------
  # フラグ操作
  # CLC (Clear C flag)  0 -> C
  def exec_CLC(_operand, _mode)
    @registers[:P][:carry] = false
  end

  # SEC (Set C flag)  1 -> C
  def exec_SEC(_operand, _mode)
    @registers[:P][:carry] = true
  end

  # CLI (Clear Interrupt disable)  0 -> I
  def exec_CLI(_operand, _mode)
    @registers[:P][:interrupt] = false
  end

  # SEI (Set Interrupt disable)  1 -> I
  def exec_SEI(_operand, _mode)
    @registers[:P][:interrupt] = true
  end

  # CLD (Clear Decimal mode)  0 -> D
  def exec_CLD(_operand, _mode)
    @registers[:P][:decimal] = false
  end

  # SED (Set Decimal mode)  1 -> D
  def exec_SED(_operand, _mode)
    @registers[:P][:decimal] = false
  end

  # CLV (Clear V flag)  0 -> V
  def exec_CLV(_operand, _mode)
    @registers[:P][:overflow] = false
  end

  #----------------------------------------------------------------------------
  # ロード
  # LDA (Load A from M)  M -> A
  def exec_LDA(operand, mode)
    __exec_LD_(:A, operand, mode)
  end

  # LDX (Load X from M)  M -> X
  def exec_LDX(operand, mode)
    __exec_LD_(:X, operand, mode)
  end

  # LDY (Load Y from M)  M -> Y
  def exec_LDY(operand, mode)
    __exec_LD_(:Y, operand, mode)
  end

  def __exec_LD_(type, operand, mode)
    @registers[type] = (mode == 'immediate' ? operand : @bus.read(operand))
    update_status_register_ng(@registers[type])
  end

  #----------------------------------------------------------------------------
  # ストア
  # STA (Store A to M)  A -> M
  def exec_STA(operand, _mode)
    __exec_ST_(:A, operand)
  end

  # STX (Store X to M)  X -> M
  def exec_STX(operand, _mode)
    __exec_ST_(:X, operand)
  end

  # STY (Store Y to M)  Y -> M
  def exec_STY(operand, _mode)
    __exec_ST_(:Y, operand)
  end

  def __exec_ST_(type, operand)
    @bus.write(operand, @registers[type])
  end

  #----------------------------------------------------------------------------
  # レジスタ間転送
  # TAX (Transfer A to X)  A -> X
  # TXA (Transfer X to A)  X -> A
  # TAY (Transfer A to Y)  A -> Y
  # TYA (Transfer Y to A)  Y -> A
  # TSX (Transfer S to X)  S -> X
  # flags: N Z

  # TXS (Transfer X to S)  X -> S
  def exec_TXS(_operand, _mode)
    # SPの上位バイトは0x01固定なので付け加える
    @registers[:SP] = @registers[:X] + 0x0100
  end

  #----------------------------------------------------------------------------
  # スタック
  # PHA (Push A on stack)  A -> stack
  # flags: none
  # PLA (Pull A from stack)  stack -> A
  # flags: N Z
  # PHP (Push P on stack)  P -> stack
  # flags: none
  # PLP (Pull P from stack)  stack -> P
  # flags: all

  #----------------------------------------------------------------------------
  # No Operation
  # NOP (No operation)
  # 何もしません。
  # flags: none
  # rubocop:enable Naming/MethodName

  #----------------------------------------------------------------------------
  # negative, zeroのステータスレジスタを更新
  def update_status_register_ng(val)
    @registers[:P][:negative] = !(val & 0x80).zero?
    @registers[:P][:zero]     = val.zero?
  end
end
# rubocop:enable Metrics/ClassLength
