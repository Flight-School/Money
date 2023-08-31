Sources/Money/Currency.swift: Resources/iso4217.csv

%.swift: %.swift.gyb
	@./gyb --line-directive '' -o $@ $<

.PHONY:
clean:
	@rm Sources/Money/Currency.swift
