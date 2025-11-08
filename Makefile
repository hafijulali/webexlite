# Makefile for webexlite

.PHONY: b64

b64:
	@if [ -f android/android-prod.keystore ]; then \
		echo "Converting android/android-prod.keystore to base64..."; \
		base64 -i android/android-prod.keystore > android/.android-prod.keystore.base64; \
		echo "Base64 content written to android/.android-prod.keystore.base64"; \
	else \
		echo "Error: android/android-prod.keystore not found."; \
		exit 1; \
	fi
