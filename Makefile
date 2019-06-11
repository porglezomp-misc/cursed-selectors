%.o: %.m
	clang -fmodules $< -c -o $@

Build/Demo: LangDemo.m ConstLang.o
	mkdir -p Build/
	clang -fmodules $^ -o $@

clean:
	rm -rf Build/ *.o
