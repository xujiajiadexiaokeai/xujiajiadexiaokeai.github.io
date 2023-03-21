#!/bin/bash

# This script will list the state of blog posts
# It will check if the 'draft' field in the markdown file is set to true or false

POSTS_DIR="content/posts"

echo "\033[31mDrafts:\033[0m"
find $POSTS_DIR -type f -name "*.md" -exec grep -q "draft: true" {} \; -print | awk '{print "\033[31m"$0"\033[0m"}'

echo "\033[32mPublished:\033[0m"
find $POSTS_DIR -type f -name "*.md" -exec grep -q "draft: false" {} \; -print | awk '{print "\033[32m"$0"\033[0m"}'
