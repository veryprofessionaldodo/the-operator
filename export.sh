mkdir -p out
cd ./src/
find -iname '*.lua' -not -name "operator.lua" -exec cat {} +> ../out/the-operator.lua
cat operator.lua >> ../out/the-operator.lua
cd ../out/
grep -v "require.*" the-operator.lua > temp && mv temp the-operator.lua