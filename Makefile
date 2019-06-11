%.o: %.m
	clang -fmodules $< -c -o $@ -g

Build/Demo: LangDemo.m ConstLang.o RPNLang.o IOLang.o
	mkdir -p Build/
	clang -fmodules $^ -o $@ -g -liovmall

clean:
	rm -rf Build/ *.o
