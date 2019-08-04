# frozen_string_literal: true

require 'logger'
require 'pry'

# PPUクラス
class Ppu
  def initialize(logger)
    @logger = logger
    @registers = Array.new(0x0008, 0)
    @vram      = Array.new(0x1000, 0)
    @palette   = Array.new(0x0020, 0)

    # レジスタのPPUADDRが下位アドレスを示しているか
    @ppuaddr_lower_flg = false
    # 書き込むPPUメモリ領域のアドレス
    @ppuaddr = 0x0000
  end

  #----------------------------------------------------------------------------
  # レジスター
  # 0x0000 | PPUCTRL   | W  | コントロールレジスタ1    | 割り込みなどPPUの設定
  # 0x0001 | PPUMASK   | W  | コントロールレジスタ2    | 背景イネーブルなどのPPU設定
  # 0x0002 | PPUSTATUS | R  | PPUステータス            | PPUのステータス
  # 0x0003 | OAMADDR   | W  | スプライトメモリデータ   | 書き込むスプライト領域のアドレス
  # 0x0004 | OAMDATA   | RW | デシマルモード           | スプライト領域のデータ
  # 0x0005 | PPUSCROLL | W  | 背景スクロールオフセット | 背景スクロール値
  # 0x0006 | PPUADDR   | W  | PPUメモリアドレス        | 書き込むPPUメモリ領域のアドレス
  # 0x0007 | PPUDATA   | RW | PPUメモリデータ          | PPUメモリ領域のデータ

  # レジスタから読み込み
  def read_reg(addr)
    case addr
    when 0x0002, 0x0004
      @registers[addr]
    when 0x0007
      read_ppudata
    else
      raise "Invalid Memory Access : #{format('0x%08X', addr)}"
    end
  end

  # レジスタに書き込み
  def write_reg(addr, data)
    case addr
    when 0x0000, 0x0001, 0x0003, 0x0004, 0x0005
      @registers[addr] = data
    when 0x0006
      update_ppuaddr(data)
    when 0x0007
      write_ppudata(data)
    else
      raise "Invalid Memory Access : #{format('0x%08X', addr)}"
    end
  end

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  private

  # 操作対象のPPUメモリ領域のアドレスを設定
  def update_ppuaddr(data)
    if @ppuaddr_lower_flg
      @ppuaddr += data
    else
      @ppuaddr = data << 8
    end
    @ppuaddr_lower_flg = !@ppuaddr_lower_flg
  end

  # PPUADDRのデータをREADする
  def read_ppudata
    @logger.debug('Not Implemented')
    0
  end

  # PPUADDRのデータをWRITEする
  def write_ppudata(data)
    case @ppuaddr
    when 0x0000...0x2000
      # write_char_ram(data)
      @logger.debug('Not Implemented')
    when 0x2000...0x3f00
      write_vram(@ppuaddr - 0x2000, data)
    when 0x3f00...0x4000
      write_palette(@ppuaddr - 0x3f00, data)
    else
      raise "Invalid Memory Access : #{format('0x%08X', @ppuaddr)}"
    end
    @ppuaddr += 1
  end

  #----------------------------------------------------------------------------
  # VRAM
  # 0x0000-0x03BF | 0x03C0 | ネームテーブル0
  # 0x03C0-0x03FF | 0x0040 | 属性テーブル0
  # 0x0400-0x07BF | 0x03C0 | ネームテーブル1
  # 0x07C0-0x07FF | 0x0040 | 属性テーブル1
  # 0x0800-0x0BBF | 0x03C0 | ネームテーブル2
  # 0x0BC0-0x0BFF | 0x0040 | 属性テーブル2
  # 0x0C00-0x0FBF | 0x03C0 | ネームテーブル3
  # 0x0FC0-0x0FFF | 0x0040 | 属性テーブル3
  # 0x1000-0x1EFF | -      | 0x0000-0x0EFFのミラー

  # VRAMに書き込み
  def write_vram(addr, data)
    @vram[addr % 0xFF] = data
  end

  #----------------------------------------------------------------------------
  # パレットテーブル
  # 0x0000-0x000F : 背景用パレット(4色x4)
  #                 各パレットの先頭は背景色扱い
  #                 0x0004, 0x0008, 0x000CをREADしたときは0x0000が返される
  # 0x0010-0x001F : スプライト用パレット(4色x4)
  #                 各パレットの先頭は透明色扱い, かつ値は背景用パレットの先頭のミラー

  # パレットに書き込み
  def write_palette(addr, data)
    target_addr = (addr % 0x04).zero? ? addr & 0x0F : addr
    @palette[target_addr] = data
  end
end
