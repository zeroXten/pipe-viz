PFont font;
ArrayList click_events;
color default_color;
color default_background;
String[] status;
HashMap elements;
String status_path;
String elements_path;
String title;

// Prepare processing
void setup() {
  size(1200,800);
  frameRate(30);
  default_color = color(0, 210, 0);
  default_background = color(0);

  noStroke;
  font = createFont("sans-serif", 18);
  large_font = createFont("sans-serif", 48);

  click_events = new ArrayList();
  elements = new HashMap();

  status_path = pathToLoadJS + "/status.csv";
  elements_path = pathToLoadJS + "/elements.csv";

  int x_offset = 50;
  int y_offset = 150;

  // Load the nodes and edges from the csv file

  String[] es = loadStrings(elements_path);
  for (int i = 0; i < es.length; i++) {
    String[] fields = splitTokens(es[i],",");
    switch(fields[0]) {
      case "node":
        String name = (String) fields[2];
        int x = (int) fields[3] + x_offset;
        int y = (int) fields[4] + y_offset;
        int w = (int) fields[5];
        int h = (int) fields[6];
        String url = (String) fields[7];

        e = new Node(name, x, y, w, h, url);
        elements.put((String) fields[1], e);
        break;
      case "edge":
        String name = (String) fields[2];
        int x = (int) fields[3] + x_offset;
        int y = (int) fields[4] + y_offset;
        int x1 = (int) fields[5] + x_offset;
        int y1 = (int) fields[6] + y_offset;
        String url = (String) fields[7];

        e = new Edge(name, x, y, x1, y1, url);
        elements.put((String) fields[1], e);
        break;
      case "title":
        title = (String) fields[1];
        break;
      case "color":
        default_color = color((int) fields[1], (int) fields[2], (int) fields[3]);
        break;
      case "background":
        default_background = color((int) fields[1], (int) fields[2], (int) fields[3]);
        break;
    }
  } 
}
  
void draw() {
  // Always clear the drawing
  background(default_background);

  textFont(large_font);
  textAlign(LEFT,TOP);
  fill(default_color);
  text(title, 50, 10);
  textFont(font);

  // Only do checks every 300 frames which at 30 frames per second is 10 seconds
  if (frameCount % 300 == 0) {

    // Reset the colours
    Iterator i = elements.entrySet().iterator();
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry)i.next();
      element = me.getValue();
      element.set_c(default_color);
    }

    // Read status values
    status = loadStrings(status_path);
    for (int i = 0; i < status.length; i++) {
      String[] fields = splitTokens(status[i],",");
      element = elements.get(fields[0]);
      if (element != null) {
        element.set_c(color((int) fields[1], (int) fields[2], (int) fields[3]));
      }
    } 
  }

  // Draw all the nodes and edges
  Iterator i = elements.entrySet().iterator();
  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
    element = me.getValue();
    element.draw();
  }

}

// Got a mouse click, see if we have any matching events
void mouseClicked() {
  for (int i = click_events.size()-1; i >= 0; i--) {
    ClickEvent event = (ClickEvent) click_events.get(i);
    if (event.click(mouseX, mouseY)) {
      break;
    }
  }
}

class Node {
  int x, y, w, h;
  String name, url;
  color c;

  Node(String name, int x, int y, int w, int h, String url) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = default_color;
    this.url = url;
    if (this.url != null) {
      this.name = this.name + "*";
      click_events.add(new ClickEvent(this.x, this.y, this.w, this.h, this.url));
    }
  }
  
  void draw() {
    noFill();
    stroke(this.c);
    strokeWeight(2);
    rect(this.x, this.y, this.w, this.h);
    noStroke();

    fill(this.c);
    textAlign(CENTER);
    text(this.name, this.x + this.w/2, this.y + this.h + 18);
    noFill();
  }

  void set_c(color c) {
    this.c = c;
  }

  color get_c() {
    return this.c;
  }
}

class Edge {
  int x, y, x1, y1;
  String name, url;
  color c;

  Edge(String name, int x, int y, int x1, int y1, String url) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.x1 = x1;
    this.y1 = y1;
    this.c = default_color;
    this.url = url;
    if (this.url != null) {
      this.name = this.name + "*";
      click_events.add(new ClickEvent(this.x + (this.x1 - this.x)/2 - 10, this.y + (this.y1 - this.y)/2 - 10, 20, 20, this.url));
    }
  }

  void draw() {
    noFill();
    stroke(this.c);
    strokeWeight(2);
    line(this.x, this.y, this.x1, this.y1);
    ellipse(this.x1, this.y1, 15, 15);
    noStroke;

    fill(this.c);
    textAlign(CENTER);
    text(this.name, this.x + (this.x1 - this.x)/2, this.y + (this.y1 - this.y)/2 + 18)
    noFill();
  }

  void set_c(color c) {
    this.c = c;
  }

  color get_c() {
    return this.c;
  }
}

class ClickEvent {
  int x, y, w, h;
  String url;
  ClickEvent(int x, int y, int w, int h, String url) {
   this.x = x;
   this.y = y;
   this.w = w;
   this.h = h;
   this.url = url;
  }

  boolean click(int x, int y) {
    if ((x >= this.x) && (x <= this.x + this.w) && (y >= this.y) && (y <= this.y + this.h)) {
      link(this.url, "_new");
      return true;
    } else {
      return false;
    }
  }
}
