# 定义变量
DEPS = main.c fuzzgoat.c
ASAN = -fsanitize=address
CFLAGS = -I.
LIBS = -lm

# 定义编译器
# AFL_CC = afl-gcc
AFL_CC = /home/test/xfuzz_work/AFLplusplus/afl-clang-fast # aflplusplus
# AFL_CC = /home/test/xfuzz_work/aflfast/afl-gcc # aflfast
# AFL_CC = /home/test/xfuzz_work/aflsmart/afl-gcc # aflsmart
# AFL_CC = /home/test/xfuzz_work/Angora/bin/angora-clang # angora
# AFL_CC = /home/test/xfuzz_work/afl-rb/afl-clang-fast # fairfuzz
# AFL_CC = /home/test/xfuzz_work/perffuzz/afl-clang-fast # perffuz
# AFL_CC = /home/test/xfuzz_work/AFL/afl-clang-fast # afl

HFUZZ_CC = /home/test/xfuzz_work/honggfuzz/hfuzz_cc/hfuzz-gcc # honggfuzz
LIBFUZZER_CC = clang # libfuzzer
RADAMSA_CC = gcc # radamsa

# 目标：fuzzgoat
all: fuzzgoat_afl fuzzgoat_libfuzzer fuzzgoat_honggfuzz  fuzzgoat_radamsa 

# for afl
fuzzgoat_afl: $(DEPS)
	$(AFL_CC) -o fuzzgoat $(CFLAGS) $^ $(LIBS)
	$(AFL_CC) $(ASAN) -o fuzzgoat_ASAN $(CFLAGS) $^ $(LIBS)

# for libfuzzer
fuzzgoat_libfuzzer: $(DEPS)
	$(LIBFUZZER_CC) -w -o fuzzgoat_libfuzzer -pthread -DFUZZING $(CFLAGS) -fsanitize=fuzzer $^ $(LIBS)

# for honggfuzz
fuzzgoat_honggfuzz: $(DEPS)
	$(HFUZZ_CC) -o fuzzgoat_honggfuzz $(CFLAGS) $^ $(LIBS)
	$(HFUZZ_CC) $(ASAN) -o fuzzgoat_honggfuzz_ASAN $(CFLAGS) $^ $(LIBS)

# for radamsa
fuzzgoat_radamsa: $(DEPS)
	$(RADAMSA_CC) -o fuzzgoat_radamsa $(CFLAGS) $^ $(LIBS)
	$(RADAMSA_CC) $(ASAN) -o fuzzgoat_radamsa_ASAN $(CFLAGS) $^ $(LIBS)

# run afl
run_afl: fuzzgoat
	# afl-fuzz -i in -o out ./fuzzgoat @@
	# /home/test/xfuzz_work/aflfast/afl-fuzz -i in -o out ./fuzzgoat @@
	# /home/test/xfuzz_work/aflsmart/afl-fuzz -i in -o out ./fuzzgoat @@
	# /home/test/xfuzz_work/Angora/bin/fuzzer -i in -o out -t ./fuzzgoat_taint -- ./fuzzgoat @@
	# /home/test/xfuzz_work/afl-rb/afl-fuzz -i in -o out ./fuzzgoat @@
	# /home/test/xfuzz_work/perffuzz/afl-fuzz -i in -o out ./fuzzgoat @@
	# /home/test/xfuzz_work/AFL/afl-fuzz -i in -o out ./fuzzgoat @@
	/home/test/xfuzz_work/AFLplusplus/afl-fuzz -i in -o out ./fuzzgoat @@

# run honggfuzz
run_honggfuzz: fuzzgoat_honggfuzz
	# honggfuzz -i in -- ./fuzzgoat_honggfuzz ___FILE___
	/home/test/xfuzz_work/honggfuzz/honggfuzz -i in -- ./fuzzgoat_honggfuzz ___FILE___

# run libfuzzer
run_libfuzzer: fuzzgoat_libfuzzer
	./fuzzgoat_libfuzzer

# run radamsa
run_radamsa: fuzzgoat_radamsa
	./run_radamsa.sh

# 清理目标
.PHONY: clean


clean:
	rm -f fuzzgoat fuzzgoat_ASAN 
	rm -rf fuzzgoat_libfuzzer 
	rm -rf fuzzgoat_honggfuzz fuzzgoat_honggfuzz_ASAN 
	rm -rf fuzzgoat_radamsa fuzzgoat_radamsa_ASAN
	rm -rf crash-*