require 'test_helper'

class ClosureCompilerTest < Test::Unit::TestCase

  ORIGINAL            = "window.hello = function(name) { return console.log('hello ' + name ); }; hello.squared = function(num) { return num * num; }; hello('world');"

  COMPILED_WHITESPACE = "window.hello=function(name){return console.log(\"hello \"+name)};hello.squared=function(num){return num*num};hello(\"world\");\n"
  COMPILED_SIMPLE     = "window.hello=function(a){return console.log(\"hello \"+a)};hello.squared=function(a){return a*a};hello(\"world\");\n"
  COMPILED_ADVANCED   = "window.a=function(a){return console.log(\"hello \"+a)};hello.b=function(a){return a*a};hello(\"world\");\n"

  def test_whitespace_compression
    js = Compiler.new(:compilation_level => "WHITESPACE_ONLY").compile(ORIGINAL)
    assert js == COMPILED_WHITESPACE
  end

  def test_simple_compression
    js = Compiler.new.compile(ORIGINAL)
    assert js == COMPILED_SIMPLE
  end

  def test_advanced_compression
    js = Compiler.new(:compilation_level => "ADVANCED_OPTIMIZATIONS").compile(ORIGINAL)
    assert js == COMPILED_ADVANCED
  end

  def test_block_syntax
    result = ''
    Compiler.new(:compilation_level => "ADVANCED_OPTIMIZATIONS").compile(ORIGINAL) do |code|
      while buffer = code.read(3)
        result << buffer
      end
    end
    assert result == COMPILED_ADVANCED
  end

  def test_jar_and_java_specifiation
    jar = Dir['vendor/closure-compiler-*.jar'].first
    compiler = Compiler.new(:java => '/usr/bin/java', :jar_file => jar)
    assert compiler.compress(ORIGINAL) == COMPILED_SIMPLE
  end

  def test_permissions
    assert File.executable?(COMPILER_JAR)
  end

end
