db.widgets.remove();
print(db.widgets.count());
db.widgets.insert({color: 'Green', price: 20});
db.widgets.insert({color: 'Green', price: 30});
db.widgets.insert({color: 'Blue', price: 20});
print(db.widgets.count());
print(db.widgets.find({color: 'Green'}).count());