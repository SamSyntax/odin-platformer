BUILD_DIR=build
BIN_NAME=platformer
.PHONY: clean run

all: clean build run

build: clean
	@mkdir -p $(BUILD_DIR)
	@odin build . -out:$(BUILD_DIR)/$(BIN_NAME)

run: build
	@$(BUILD_DIR)/$(BIN_NAME)

clean:
	@rm -rf $(BUILD_DIR)/$(BIN_NAME)


