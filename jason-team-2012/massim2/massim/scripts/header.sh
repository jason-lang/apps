#!/bin/bash

package=$( ls -t ../target/agentcontest-*.jar | grep -v javadoc | grep -v sources | head -n1 )

