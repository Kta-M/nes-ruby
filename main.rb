# frozen_string_literal: true

require 'logger'
require './rom'
require './nes'

# ヘルプメッセージ
HELP_MSG = <<-MSG
  usage: ruby main.rb <command> [parameters]

  ruby main.rb run path/to/rom
  ruby main.rb version
  ruby main.rb help
MSG

# バージョン
VERSION = '0.0.1'

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ロガー作成
def create_logger(out, level)
  logger = Logger.new(
    out,
    formatter: proc { |severity, datetime, _progname, msg|
      "[#{(severity + ' ' * 5)[0, 5]}] #{datetime.strftime('%H:%M:%S %6N')} | #{msg}\n"
    }
  )
  logger.level = level
  logger.debug("Create logger: out #{out}, level #{level}")
  logger
end

# メイン
def main
  # バージョン表示
  if ARGV[0] == 'version'
    puts VERSION
    return
  end

  # ヘルプ
  if ARGV[0] == 'help'
    puts HELP_MSG
    return
  end

  # ロガー作成
  logger = create_logger(STDOUT, Logger::DEBUG)

  # 実行
  if ARGV[0] == 'run' && ARGV[1].match(/\.nes\Z/)
    binary = File.binread(ARGV[1])
    rom = Rom.new(binary, logger)
    nes = Nes.new(rom, logger)
    nes.run
    return
  end

  # 不正な引数
  logger.error('Invalid command or parameters')
  puts HELP_MSG

rescue StandardError => e
  logger.fatal(e)
  puts e.backtrace
end

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 実行
main
