#!/usr/bin/env bash

# Author: Abid Sulaiman
# Title: Test Script for Sound Control

test_exit_code_success() {
	if [[ $? -eq 0 ]]; then
		echo "Exit code set correctly"
	else
		echo "Exit code set incorrectly"
	fi
}

test_exit_code_fail() {
	if [[ $? -ne 0 ]]; then
		echo "Exit code set correctly"
	else
		echo "Exit code set incorrectly"
	fi
}

# Test Output Result ------------------------------------

# Test Get Input
re='^\[o(n)?(ff)?\]' # on or off
res=$(./sound-ctl.sh gi)

if [[ "$res" =~ $re ]]; then
	echo "Test get input status OK"
	test_exit_code_success
else
	echo "Test get input status failed."
	echo "Consider running setup script or check your inputSource variable."
	test_exit_code_fail
	exit 1
fi

echo # blank line

# Test Get Output
re='^H?S?P$' # HP or SP
res=$(./sound-ctl.sh go)
if [[ "$res" =~ $re ]]; then
	echo "Test get output status OK"
	test_exit_code_success
else
	echo "Test get output status failed."
	echo "Consider running setup script or check your outputSink, speakerPort and headphonePort variable."
	exit 1
	test_exit_code_fail
fi

echo # blank line

# Test Get Volume
re='^1?[0-9]{2}' # on or off
res=$(./sound-ctl.sh gv)

if [[ "$res" =~ $re ]]; then
	echo "Test get volume OK"
	test_exit_code_success
else
	echo "Test get volume failed."
	echo "Consider running setup script or check your output variable."
	test_exit_code_fail
	exit 1
fi

echo # blank line

# Test Command ------------------------------------------
# with correct config -----------------------------------

options=("gi" "go" "gv" "i" "o" "sv 50")

echo "Test with correct config"
echo # blank line
for o in "${options[@]}"; do
	echo "Test option" "$o"
	./sound-ctl.sh $o
	test_exit_code_success
	echo # blank line
done

# Test Command ------------------------------------------
# with incorrect config ---------------------------------

# Copy script and clear config to cause error.
cp ./sound-ctl.sh ./sound-ctl-error.sh
sed -i '/outputSink=/,/headphonePort=/s/".*"/""/' ./sound-ctl-error.sh

echo "Test with incorrect config"
echo # blank line
for o in "${options[@]}"; do
	echo "Test option" "$o"
	./sound-ctl-error.sh $o
	test_exit_code_fail
	echo # blank line
done

rm ./sound-ctl-error.sh

echo "Test finished successfully"

exit 0
