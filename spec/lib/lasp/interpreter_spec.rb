require "spec_helper"
require "lasp"
require "tempfile"

module Lasp
  describe Interpreter do
    let(:env) { Lasp.env_with_corelib }

    def execute(program, environment = env)
      Lasp.execute(program, environment)
    end

    it "handles simple forms" do
      expect(execute("(+ 1 1)")).to eq 2
    end

    it "handles nested forms" do
      expect(execute("(+ 1 (+ 2 2))")).to eq 5
    end

    describe "symbol resolution" do
      it "resolves a symbol to its value" do
        expect(execute("fourty-two", :"fourty-two" => 42)).to eq 42
      end

      it "raises a NameError when trying to resolve a non existing symbol" do
        expect { execute("not-here") }.to raise_error(Lasp::NameError, /not-here is not present in this context/)
      end

      it "resolves symbols that start with an uppercase letter as Ruby objects" do
        expect(execute("Math")).to eq Math
      end

      it "resolves nested Ruby objects with slashes" do
        expect(execute("Math/PI")).to eq Math::PI
      end
    end

    describe "special forms" do
      describe "def" do
        it "defines values in the environment" do
          execute("(def five 5)")

          expect(env.fetch(:five)).to eq 5
        end

        it "returns the value it sets" do
          expect(execute("(def five 5)")).to eq 5
        end

        it "only allows defining symbols" do
          expect { execute("(def \"str\" 5)") }.to raise_error(Lasp::ArgumentError)
          expect { execute("(def (list) 5)") }.to raise_error(Lasp::ArgumentError)
        end
      end

      describe "fn" do
        it "creates a function" do
          expect(execute("(fn (x) (+ x 1))")).to be_a Fn
        end

        it "enforces arity" do
          expect {
            execute("((fn (x) (+ x 1)) 3 6)")
          }.to raise_error(Lasp::ArgumentError, "wrong number of arguments (2 for 1)")
        end

        it "executes defined functions" do
          execute("(def inc (fn (x) (+ x 1)))")
          expect(execute("(inc 1)")).to eq 2
        end

        it "handles closures" do
          # This is a function that takes an argument, and returns another
          # function that simply returns the argument of the outer function on
          # invocation; this is what the outer parenthesis are for: to execute
          # the inner function too. What is important here is that the inner
          # function has access to the environment in the outer one.
          expect(execute("(((fn (x) (fn () x)) 42))")).to eq 42
        end
      end

      describe "do" do
        it "executes multiple statements in order" do
          mock_fn  = spy
          test_env = Env.new(test: mock_fn)

          execute("(do (test 1) (test 2))", test_env)

          expect(mock_fn).to have_received(:call).with(1).ordered
          expect(mock_fn).to have_received(:call).with(2).ordered
        end

        it "returns the value of the last statement" do
          expect(execute("(do (+ 1 1) (+ 1 2))")).to eq 3
        end
      end

      describe "if" do
        it "returns the result of the correct form" do
          expect(execute("(if (= 1 1) true false)")).to eq true
          expect(execute("(if (= 1 2) true false)")).to eq false
          expect(execute("(if (= 1 2) true)")).to eq nil
        end

        it "does not evaluate the other form" do
          # This is different than simply not returning its result, the other
          # form cannot even be evaluated.
          mock_fn  = spy
          test_env = env.merge(test: mock_fn)

          execute('(if (= 1 1) true (test "not evaled!"))', test_env)

          expect(mock_fn).not_to have_received(:call)
        end
      end

      describe "quote" do
        it "returns symbol without evaluating it" do
          expect(execute("(quote f)")).to eq :f
        end

        it "returns form without evaluating it" do
          expect(execute("(quote (f 1 2))")).to eq [:f, 1, 2]
        end

        it "only quotes the first argument" do
          expect(execute("(quote f g)")).to eq :f
        end
      end

      describe "macro" do
        it "creates macros" do
          expect(execute("(macro (x) x)")).to be_a Macro
        end

        it "gives macros unevaluated forms as arguments" do
          expect(execute("((macro (one op two) (list op one two)) 1 + 2)")).to eq 3
        end
      end

      describe "require" do
        it "carries the env" do
          with_tempfile("(def test true)") do |file|
            execute("(require \"#{file.path}\")")
            expect(execute("test")).to eq true
          end
        end

        it "executes a file with a path relative to the directory Läsp was started in" do
          require_path  = "./path/test.lasp"
          expected_path = File.expand_path("path/test.lasp", product_root)

          expect(Lasp).to receive(:execute_file).with(expected_path, an_instance_of(Env))

          execute("(require \"#{require_path}\")")
        end

        it "uses a path relative to the file when passed a truthy second argument" do
          required_file = "test.lasp"

          with_tempfile("(require \"#{required_file}\" true)") do |file|
            expected_path = File.expand_path(File.join(file.path, "../", required_file))
            expect(Lasp).to receive(:execute_file).with(expected_path, an_instance_of(Env))

            # Set up things to have this explicit call to execute_file not interfere with the test
            env = Lasp.env_with_corelib
            allow(Lasp).to receive(:execute_file).with(file.path, env).and_call_original

            Lasp.execute_file(file.path, env)
          end
        end
      end
    end

    it "does ruby interop" do
      expect(execute('(.upcase "hello")')).to eq "HELLO"
    end
  end
end
