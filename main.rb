$homebrew = `brew --repository`.strip
$homebrew_core = "#{$homebrew}/Library/Taps/homebrew/homebrew-core"
$homebrew_formula = "#{$homebrew_core}/Formula/*.rb"
# These ignore invalid option and request user response like sudo
$blacklist = [
    'cssembed',
    'aldo',
    'jvmtop',
    'rlvm',
    'gearsystem',
    'cntlm',
    'ppsspp',
    'chocolate-doom',
    'latex2rtf',
    'lci',
    'ii',
    'redstore',
    'einstein',
    'virtualhost.sh',
    'ballerburg',
    'xspin',
    'qcachegrind',
    'nuvie',
    'gearboy',
    'peg',
    'term',
    'lv',
    'pngnq',
    'memcache-top',
    'mcpp',
    'cmigemo',
    'openjazz',
    'pianobar',
]

def check_formula(path)
  name = File.basename path, '.rb'
  return if $blacklist.include?(name)
  File.open(path) do |file|
    file.each_line do |line|
      if line.include? 'test do'
        #puts "[#{name}] OK"
        return
      end
    end
    execute_version_command(name, path)
  end
end

def execute_version_command(name, path)
  unless system("brew install #{name}&>/dev/null")
    puts "[#{name}] \e[31mINSTALLATION FAILED\e[0m"
    return
  end
  puts "[#{name}] executing"
  ["#{name} --version", "#{name} -v", "#{name} --help"].each do |command|
    if system("#{command}&>/dev/null")
      append_test(name, path, command)
      return
    end
  end
  puts "[#{name}] \e[31mCOMMAND NOT FOUND\e[0m"
end

def append_test(name, path, command)
  formula = File.read(path).gsub(/^end/, <<~RUBY)
  
      test do
        system('#{command}')
      end
    end
  RUBY
  File.open(path, 'w') do |file|
    file.puts formula
  end
  test_formula(name, path)
end

def test_formula(name, path)
  Dir.chdir($homebrew_core) do
    unless system("brew test #{name}")
      system 'git reset --hard HEAD'
      puts "[#{name}] \e[31mTEST FAILED\e[0m"
      return
    end
    `git add #{path}`
    `git commit -m "#{name}: add test"`
    puts "[#{name}] ADDED TEST"
  end
end

puts "Start checking formulae in '#{$homebrew_formula}'"
Dir.glob($homebrew_formula) do |path|
  check_formula(path)
end