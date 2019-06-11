%.o: %.m
	clang -fmodules $< -c -o $@ -g

Build/Demo: LangDemo.m ConstLang.o RPNLang.o
	mkdir -p Build/
	clang -fmodules $^ -o $@ -g

clean:
	rm -rf Build/ *.o
