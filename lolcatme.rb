require 'byebug'
require 'fileutils'

class LolcatMe
  IGNORE_COMMANDS = %w|
    vi vim emacs nano
    bash fish zsh
    ssh mosh
    open man
  |

  def self.lolcatify
    new.lolcatify
  end

  def lolcatting?
    true
  end

  def lolcatify
  end

  def ensure_dir opts
    path = expand opts[:path]
    FileUtils.mkdir_p path
  end

  def backup opts
    path = expand(opts[:path])
    timestamp = Time.now.strftime '%Y_%m_%d_%H_%M_%S'
    backup_dir = File.join expand('~/.dots_backup'), timestamp
    copied_file = File.join backup_dir, File.basename(path)

    return unless File.exist? path

    ensure_dir path: backup_dir
    puts "backing up #{path} to #{copied_file}"
    FileUtils.cp path, copied_file
  end

  def contains?(opts)
    path = opts[:path]
    match = opts[:match]

    File.open(expand(path), 'r').each_line.any? { |l| l =~ match }
  end

  def exists? opts
    path = expand opts[:path]
    File.exist? path
  end

  def append_content(opts)
    path = opts[:path]
    content = opts[:content]

    backup path: path

    File.open expand(path), 'a' do |file|
      file.puts
      file.puts content
      file.puts
    end
  end

  def insert_content(opts)
    path = opts[:path]
    content = opts[:content]
    match = opts[:match]

    return unless contains? path: path, match: match

    backup path: path

    lines = File.readlines expand(path)
    matched = false
    File.open(expand(path), 'w') do |file|
      lines.each do |line|
        file.print line

        if line =~ match && ! matched
          file.print content
          matched = true
        end
      end
    end
  end

  def replace_content(opts)
    path = opts[:path]
    content = opts[:content]

    backup path: path

    File.open expand(path), 'w' do |file|
      file.puts content
    end
  end

  protected

  def expand path
    File.expand_path path
  end
end

class LolcatBash < LolcatMe
  BASH_DESTINATION = '~/.bash_profile'
  FUNCTION_FILE = '~/.lolcatme.bash'

  def lolcatting?
    contains? path: BASH_DESTINATION, match: /#{Templates.bash_profile}/
  end

  def lolcatify
    unless exists? path: BASH_DESTINATION
      puts 'cant lolcatty bash'
      return
    end

    if lolcatting?
      puts 'already lolcatting in bash'
      return
    else
      puts 'locatted'
      append_content path: BASH_DESTINATION, content: Templates.bash_profile
      replace_content path: FUNCTION_FILE, content: Templates.function
      replace_content path: '~/.bash_sessions_disable', content: ''
    end
  end

  class Templates
    def self.function
      <<-BASH
        function lolcatme() {
          which -s lolcat
          if [ $? -ne 0 ]; then
            echo no lolcat
            return 0
          fi

          if [[ "$BASH_COMMAND" == "$PROMPT_COMMAND" ]]; then
            return 0
          fi

          if [ -e /etc/bashrc_Apple_Terminal ]; then
            grep -F --quiet "'$BASH_COMMAND'" /etc/bashrc_Apple_Terminal
            if [ $? -eq 0 ]; then
              echo terminal boot sequence
              return 0
            fi
          fi

          unsafe_commands=(#{ LolcatMe::IGNORE_COMMANDS.map {|cmd| "'#{cmd}'" }.join ' ' })
          unsafe_commands+=('shell_session_history_check' 'update_terminal_cwd')
          for cmd in "${unsafe_commands[@]}"; do
            if [[ "'"$BASH_COMMAND"'" =~ $cmd.* ]]; then
              echo unsafe command: $BASH_COMMAND
              return 0
            fi
          done

          $BASH_COMMAND | lolcat
          return 2
        }

        shopt -s extdebug

        trap 'lolcatme' DEBUG
      BASH
    end

    def self.bash_profile
      "source #{FUNCTION_FILE}"
    end
  end
end

class LolcatFish < LolcatMe
  FISH_DESTINATION = '~/.config/fish/config.fish'
  FUNCTION_FILE    = '~/.config/fish/functions/lolcatme.fish'

  def lolcatting?
    contains? path: FISH_DESTINATION, match: /bind \\r 'lolcatme'/
  end

  def lolcatify
    unless exists? path: FISH_DESTINATION
      puts 'cant lolcatty fish'
      return
    end

    if lolcatting?
      puts 'already lolcatting fish'
      return
    end

    puts 'lolcatted'

    ensure_dir path: File.dirname(FUNCTION_FILE)
    replace_content path: FUNCTION_FILE, content: Templates.function

    unless contains? path: FISH_DESTINATION, match: /function fish_user_key_bindings/
      append_content path: FISH_DESTINATION, content: Templates.user_key_bindings
    end

    insert_content path: FISH_DESTINATION, match: /function fish_user_key_bindings/, content: Templates.binding
  end

  class Templates
    def self.user_key_bindings
      <<-FISH
        function fish_user_key_bindings
        end
      FISH
    end

    def self.binding
      "  bind \\r 'lolcatme'\n"
    end

    def self.function
      <<-FISH
        function lolcatme
          set -l cmd (commandline)
          set -l first (commandline --tokenize)[1]

          if not contains $first #{LolcatMe::IGNORE_COMMANDS.join ' '} history
            # prepend space to prevent polluting the history
            commandline --replace " $cmd | lolcat"
          end

          commandline -f execute
        end
      FISH
    end
  end
end

class LolcatZsh < LolcatMe
  ZSH_DESTINATION = '~/.zshrc'
  FUNCTION_FILE = '~/.zsh/lolcat.zsh'

  def lolcatting?
    contains? path: ZSH_DESTINATION, match: /#{Templates.trap}/
  end

  def lolcatify
    unless exists? path: ZSH_DESTINATION
      puts 'cannot lolcatty zsh'
      return
    end

    if lolcatting?
      puts 'already lolcatted zsh'
      return
    end

    puts 'lolcatted zsh'

    ensure_dir path: File.dirname(FUNCTION_FILE)
    replace_content path: FUNCTION_FILE, content: Templates.function
    append_content  path: ZSH_DESTINATION, content: Templates.trap
  end

  class Templates
    def self.function
      <<-ZSH
        function lolcatme() {
          unsafe_commands=(#{ LolcatMe::IGNORE_COMMANDS.map {|cmd| "'#{cmd}'" }.join ' ' })
          unsafe_commands+=(setopt)

          for cmd in $unsafe_commands; do
            if [[ "'"$ZSH_DEBUG_CMD"'" =~ $cmd.* ]]; then
              return 0
            fi
          done

          eval ${ZSH_DEBUG_CMD} | lolcat

          setopt ERR_EXIT
        }

        trap 'lolcatme' DEBUG
        setopt DEBUG_BEFORE_CMD
      ZSH
    end

    def self.trap
      "source #{FUNCTION_FILE}"
    end
  end
end

LolcatBash.lolcatify
LolcatFish.lolcatify
LolcatZsh.lolcatify
