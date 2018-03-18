$homebrew = `brew --repository`.strip
$homebrew_core = "#{$homebrew}/Library/Taps/homebrew/homebrew-core"
$homebrew_formula = "#{$homebrew_core}/Formula/*.rb"
$targets = [
    'griffon',
    'wwwoffle',
    'foremost',
    'rdiff-backup',
    'cgdb',
    'fatsort',
    'lockrun',
    'icecast',
    'sloccount',
    'bokken',
    'mp3gain',
    'cdargs',
    'plenv',
    'qstat',
    'epsilon',
    'iat',
    'mussh',
    'beanstalkd',
    'wiggle',
    'redsocks',
    'git-open',
    'xmlstarlet',
    'git-number',
    'ripmime',
    'streamripper',
    'xmlformat',
    'dnstop',
    'mairix',
    'pbrt',
    'naturaldocs',
    'xmlcatmgr',
    'dcfldd',
    'ocp',
    'aview',
    'webkit2png',
    'madplay',
    'winexe',
    'tnef',
    'mkvdts2ac3',
    'echoprint-codegen',
    'pbzip2',
    'tcpsplit',
    'tcpflow',
    'xmp',
    'star',
    'pktanon',
    'cdpr',
    'lcov',
    'dvdbackup',
    'xcproj',
    'ifstat',
    'kytea',
    'dcled',
    'pdfcrack',
    'iphotoexport',
    'mogenerator',
    'launch4j',
    'httperf',
    'rsnapshot',
    'arm',
    'thrift',
    'pdftohtml',
    'gtmess',
    'wakeonlan',
    'makepp',
    'bogofilter',
    'gcab',
    'nload',
    'htmldoc',
    'redo',
    'arss',
    'shocco',
    'keychain',
    'snownews',
    'cdparanoia',
    'blahtexml',
    'doubledown',
    'proxytunnel',
    'esniper',
    'davmail',
    'doublecpp',
    'swfmill',
    'vorbisgain',
    'rlwrap',
    'wy60',
    'bbe',
    'tidyp',
    'wry',
    'nkf',
    'mpg321',
    'gpp',
    'bsdsfv',
    'gpsim',
    'id3v2',
    'sntop',
    'mpgtx',
    'movgrab',
    'yydecode',
    'crunch',
]

def execute_formula(path)
  name = File.basename path, '.rb'
  return unless $targets.include?(name)
  system "brew install #{name}"

  %w[--version --help].each do |flag|
    next unless system("#{name} #{flag}")
    update_formula(name, path, flag)
    test_formula(name, path)
    return
  end
  puts "#{name} command not found"
end

def update_formula(name, path, flag)
  formula = File.read(path).gsub(/^end/, <<~RUBY.chomp)
  
      test do
        system "\#{bin}/#{name}", "#{flag}"
      end
    end
RUBY
  File.open(path, 'w') do |file|
    file.puts formula
  end
end

def test_formula(name, path)
  Dir.chdir($homebrew_core) do
    system "brew uninstall --force #{name}"
    system "brew install --build-from-source #{name}"
    system "brew test #{name}"
    if system("brew audit --strict #{name}")
      puts "commiting #{name}"
      system "git add #{path}"
      system "git commit -m '#{name}: add test'"
      puts "\e[32mSUCCESSFUL\e[0m"
    else
      system 'git reset --hard HEAD'
    end
    system "brew uninstall --force #{name}"
  end
end

Dir.glob($homebrew_formula) do |path|
  execute_formula(path)
end