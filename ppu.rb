# frozen_string_literal: true

require 'logger'
require 'pry'

# PPUクラス
class Ppu
  def initialize(logger)
    @logger = logger
    @registers = Array.new(0x0008)
  end

  #----------------------------------------------------------------------------
  # レジスター
  def read_reg(addr)
    raise "Invalid Memory Access : #{format('0x%08X', addr)}" if addr >= 0x0008

    @registers[addr]
  end

  def write_reg(addr, data)
    raise "Invalid Memory Access : #{format('0x%08X', addr)}" if addr >= 0x0008

    @registers[addr] = data
  end
end
