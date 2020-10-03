
require "gtk3"
require 'sqlite3'
require "pango"

def print_liststore_from_db (begin_date,finish_date,db,liststore,plus,minus,total)
result=db.query("Select * 
	from money 
	where date >='#{begin_date}' and date <='#{finish_date}'
	order by date desc")
liststore.clear
sum=0
sump=0;
summ=0

while (db_row = result.next) do
    iter=liststore.append()
 (0..db_row.size-1).each {|i| iter[i]=db_row[i]}
 iter[0]=iter[0][8,2]+"/"+iter[0][5,2]
sum+=db_row[2]
if db_row[2]>0
	sump+=db_row[2]
else
	summ+=db_row[2]
end	
end
plus.text=sump.to_s
minus.text=summ.to_s
total.text=sum.to_s

end

width = 716
height = 405
Gtk.init

db = SQLite3::Database.open 'money.db'
unless db.errcode
  print "Database error code-",db.errcode,"\n";
  print "Database error msg-",db.errmsg,"\n";
end



window = Gtk::Window.new("Toplevel")
window.title = "Check your ballance"
window.override_background_color('normal',"#323c4e")
window.override_color('normal',"#3AD900")
window.set_default_size(width,height)
window.position='center'
window.resizable=false
window.border_width=20
window.signal_connect("destroy") { Gtk.main_quit }

text_f1=Pango::FontDescription.new("Normal bold 12")
text_f2=Pango::FontDescription.new("Normal  16")

columns= ["Дата","От кого","Сумма"]
columns_size = columns.size

liststore=Gtk::ListStore.new(String,String,Integer);
list_money=Gtk::TreeView.new(liststore)
list_money.override_font(text_f2)
scrollwindow_list_money=Gtk::ScrolledWindow.new();
scrollwindow_list_money.set_min_content_height(190);
scrollwindow_list_money.set_min_content_width(450);
scrollwindow_list_money.set_policy('automatic','automatic');
scrollwindow_list_money.add(list_money);
# list_money.columns_autosize

cell=Gtk::CellRendererText.new();
col=Gtk::TreeViewColumn.new(columns[0],cell,:text=>0);
col.resizable=true;
col.set_sizing('FIXED')
col.fixed_width =100
list_money.append_column(col);

cell=Gtk::CellRendererText.new();
col=Gtk::TreeViewColumn.new(columns[1],cell,:text=>1);
col.resizable=true;
col.set_cell_data_func(cell){|column, cell, model,iter|
if model.get_value(iter,1)=="ЗП"
	cell.set_property("background", "yellow") 
else
	cell.set_property("background", "white")
end
}
col.set_sizing('FIXED')
col.fixed_width =230
list_money.append_column(col);

cell=Gtk::CellRendererText.new();
col=Gtk::TreeViewColumn.new(columns[2],cell,:text=>2);
col.resizable=true;
col.set_sizing('FIXED')
col.set_cell_data_func(cell){|column, cell, model,iter|
if model.get_value(iter,2)<0
	cell.set_property("background", "red") 
elsif model.get_value(iter,2)>1000
	cell.set_property("background", "orange")
else
	cell.set_property("background", "white") 
end

}
list_money.append_column(col);





label_p = Gtk::Label.new('')
label_p.set_xalign(1)
label_p.override_font(text_f1)
label_m = Gtk::Label.new('')
label_m.set_xalign(1)
label_m.override_font(text_f1)
label_t = Gtk::Label.new('')
label_t.set_xalign(1)
label_t.override_font(text_f1)


dt1=Gtk::Calendar.new()
dt1.set_display_options (:SHOW_HEADING)
dt1.set_day 1


dt2=Gtk::Calendar.new()
last_day=[31,28,31,30,31,30,31,31,30,31,30,31]
dt2.set_day last_day[dt2.month]
dt2.set_display_options (:SHOW_HEADING)

f_date=sprintf "%4d-%02d-%02d",dt1.date[0],dt1.date[1],dt1.date[2]
l_date=sprintf "%4d-%02d-%02d",dt2.date[0],dt2.date[1],dt2.date[2]
print_liststore_from_db(f_date,l_date,db,liststore,label_p,label_m, label_t)

dt1.signal_connect('day-selected'){
f_date=sprintf "%4d-%02d-%02d",dt1.date[0],dt1.date[1],dt1.date[2]
l_date=sprintf "%4d-%02d-%02d",dt2.date[0],dt2.date[1],dt2.date[2]
print_liststore_from_db(f_date,l_date,db,liststore,label_p,label_m, label_t)
}

dt2.signal_connect('day-selected'){
f_date=sprintf "%4d-%02d-%02d",dt1.date[0],dt1.date[1],dt1.date[2]
l_date=sprintf "%4d-%02d-%02d",dt2.date[0],dt2.date[1],dt2.date[2]
print_liststore_from_db(f_date,l_date,db,liststore,label_p,label_m, label_t)
}

entry_name = Gtk::Entry.new();
entry_name.set_text  "Atlant"

entry_name.override_font(text_f1)
entry_money = Gtk::Entry.new();
entry_money.set_text "1000"
entry_money.max_length=6
entry_money.width_chars=6

entry_money.override_font(text_f1)
button_add = Gtk::Button.new();
button_add.override_background_color('normal',"#adf6b4")
button_add.set_label('Add');
button_add.set_relief('none');
button_add.signal_connect('clicked') {
	puts Date.today
	db.execute("insert into money (date,rashod,summa) values(?,?,?)",Date.today.to_s,entry_name.text,entry_money.text)
}

hbox1=Gtk::Box.new('horizontal',20);
hbox1.pack_start(entry_name,:expand=>true,:fill=>true);
hbox1.pack_start(entry_money,:expand=>false,:fill=>false);
hbox1.pack_end(button_add,:expand=>false,:fill=>false);
hbox1.set_homogeneous(false);






vbox1 = Gtk::Box.new('vertical',20);
vbox1.pack_start(dt1,:expand=>false,:fill=>false,:padding=>10);
vbox1.pack_start(dt2,:expand=>false,:fill=>false,:padding=>10);
vbox1.pack_start(label_p,:expand=>false,:fill=>false);
vbox1.pack_start(label_m,:expand=>false,:fill=>false);
vbox1.pack_end(label_t,:expand=>false,:fill=>false);

vbox1.set_homogeneous(false);



grid = Gtk::Grid.new()

grid.row_spacing=20
grid.column_spacing=20;
grid.column_homogeneous=true;
grid.attach(hbox1,0,0,2,1);
grid.attach(scrollwindow_list_money,0,1,2,13);
grid.attach(vbox1,2,0,1,14);
window.add(grid)
window.show_all
Gtk.main
