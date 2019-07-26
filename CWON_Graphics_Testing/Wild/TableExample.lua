function tlen(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function getindexatpos(tab, sp)
    local p = 1
    local si
    for i, e in pairs(tab) do
        if p == sp then
            si = i
            break
        end
        p = p + 1
    end
    return si
end

function getelementatpos(tab, sp)
    return tab[getindexatpos(tab, sp)]
end

a = {5}
a[10] = 11
a[15] = 13
a[23] = 16
a[43] = 3443
a[294] = 111

for i, v in pairs(a) do
    print(i, v)
end
print("---")
print(tlen(a))

a[10] = nil
a[294] = nil
table.remove(a,1)

print("---")



math.randomseed(os.time())



print("---")

r = math.random(tlen(a))
ind = getindexatpos(a,r)
for i, v in pairs(a) do
    print(i, v)
end
print("tlen:" .. tlen(a))
print("rand:" .. r)
print("index at pos:" .. ind)
print("selected element:" .. getelementatpos(a,r))

select = {}
table.insert(select, getelementatpos(a,r))

a[ind] = nil


print("---")

r = math.random(tlen(a))
ind = getindexatpos(a,r)
for i, v in pairs(a) do
    print(i, v)
end
print("tlen:" .. tlen(a))
print("rand:" .. r)
print("index at pos:" .. ind)
print("selected element:" .. getelementatpos(a,r))


table.insert(select, getelementatpos(a,r))

for i, v in pairs(select) do
    print(i, v)
end



iain = {}
iain["name"] = "Iain"
iain["age"] = 40

peeps = {}

table.insert(peeps, iain)

for i, v in pairs(peeps) do
    print(i, v["name"], v["age"])
end