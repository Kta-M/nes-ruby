# frozen_string_literal: true

require 'logger'
require './rom'

# エミュレータークラス
class Nes
  def initialize(rom, logger)
    @rom = rom
    @logger = logger
  end

  def run
    @logger.info('Start emulation')
  end
end
