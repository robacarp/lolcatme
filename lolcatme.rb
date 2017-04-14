require 'fileutils'

class LolcatMe
  IGNORE_COMMANDS = %w|
    vi vim emacs nano
    bash fish zsh csh ksh
    ssh mosh
    open man help info
    export env local set
    eval alias
    case for if then else test
    builtin print printf command test setopt unsetopt bindkey emulate title echoti echotc typeset url-quote-magic zstyle zle
  |

  def self.lolcatify
    new.lolcatify
  end

  def lolcatting?
    true
  end

  def lolcatify
  end

  def self.install_help_message
    message = <<-HELP
    Hey there! If you're reading this, you're probably reading this in rainbows. :]

    Hopefully the rainbows didn't cause you too much disruption...it's designed as a harmless prank.

    Here are the removal instructions, by shell, ranked in order of shell coolness:

    - Fish:
      In your ~/.config/fish/config.fish, search for and remove this line: #{LolcatFish::Templates.binding}
      Remove this file: #{LolcatFish::FUNCTION_FILE}

    - Zsh:
      In your ~/.zshrc, search for and remove this line: #{LolcatZsh::Templates.trap}
      Remove this file: #{LolcatZsh::FUNCTION_FILE}

    - Bash:
      Why are you using bash? ;-) Hopefully you didn't have a bad time with lolcatme...bash is brutal to mitm the cli.

      In your ~/.bash_profile, search for and remove this line: #{LolcatBash::Templates.bash_profile}
      Remove this file: #{LolcatBash::FUNCTION_FILE}
      Remove this file: #{LolcatBash::DISABLE_APPLE_SESSIONS_FILE}

    All files which are changed or overwritten are backed up in ~/.dots_backup/[datetime]/.
    If something has gone terribly wrong, restore from backup there. Otherwise, you can probably delete the ~/.dots_backup folder.
    HELP

    new.replace_content path: '~/AA_HELP_I_HATE_RAINBOWS.txt', content: message, backup: false
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
    puts "\tbacking up #{path} to #{copied_file}"
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

    backup path: path unless opts[:backup] == false

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
  DISABLE_APPLE_SESSIONS_FILE = '~/.bash_sessions_disable'

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
      puts 'locatting bash'

      append_content path: BASH_DESTINATION, content: Templates.bash_profile
      replace_content path: FUNCTION_FILE, content: Templates.function, backup: false
      replace_content path: DISABLE_APPLE_SESSIONS_FILE, content: '', backup: false
    end
  end

  class Templates
    def self.function
      <<-BASH
        function lolcatme() {
          which -s lolcat > /dev/null
          if [ $? -ne 0 ]; then
            return 0
          fi

          if [[ "$BASH_COMMAND" == "$PROMPT_COMMAND" ]]; then
            return 0
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

    puts 'lolcatting fish'

    ensure_dir path: File.dirname(FUNCTION_FILE)
    replace_content path: FUNCTION_FILE, content: Templates.function, backup: false

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
          set -l errors 0

          # dont try to lolcat when it isnt installed
          which -s lolcat
          if test $status -eq 0
            set errors (math $errors + 1)
          end

          set -l cmd (commandline)
          set -l first (commandline --tokenize)[1]
          set -l last_char (string sub --start=-1 $cmd)

          # dont lolcat a bunch of commands which dont play well with pipes
          if not contains $first #{LolcatMe::IGNORE_COMMANDS.join ' '} history
            set errors (math $errors + 1)
          end

          # dont lolcat when the command is blank
          if test -n $cmd
            set errors (math $errors + 1)
          end

          # dont lolcat when the command ends in a slash or tilde (directory change)
          if test $last_char = '/' -o $last_char = '~'
            set errors (math $errors + 1)
          end


          # if there arent any problems, lolcat the command
          # - prepend space to prevent polluting the autocomplete history
          if test $errors -eq 0
            commandline --replace " $cmd | lolcat"
          end

          # execute the command line
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

    puts 'lolcatting zsh'

    ensure_dir path: File.dirname(FUNCTION_FILE)
    replace_content path: FUNCTION_FILE, content: Templates.function, backup: false
    append_content  path: ZSH_DESTINATION, content: Templates.trap
  end

  class Templates
    def self.function
      <<-ZSH
        function lolcatme() {
          [ $lolcat_available -eq 0 ] || return 0

          unsafe_commands=' #{LolcatMe::IGNORE_COMMANDS.join ' '} [[ '

          # does the command contain an =?
          if test "${ZSH_DEBUG_CMD#*'='}" != $ZSH_DEBUG_CMD; then
            return 0
          fi

          # what's the first word in the command
          first_word=" ${${(@z)ZSH_DEBUG_CMD}[1]} "
          if test "${unsafe_commands#*$first_word}" != $unsafe_commands; then
            return 0
          fi

          eval $ZSH_DEBUG_CMD | lolcat
          setopt ERR_EXIT
        }

        whence lolcat > /dev/null
        export lolcat_available=$?

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
LolcatMe.install_help_message
