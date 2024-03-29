import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { MatTabChangeEvent } from '@angular/material';
import {APAFormatPipe, CoAuthorsPipe, KeysPipe} from './pipes';
import { ActivatedRoute } from "@angular/router";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})

export class AppComponent  {
  data: any; 
  accepted = false;
  showall=false;
  apaformat=false;
  constructor(private http: HttpClient, private route: ActivatedRoute) {
    this.http.get("assets/data.json").subscribe( res => {  this.data=res; CoAuthorsPipe.me = this.data.about.name; });
  }

  ngOnInit() {
    this.route.queryParamMap.subscribe(params => {
      let showall = this.route.snapshot.queryParamMap.get("showall");
      let accepted = this.route.snapshot.queryParamMap.get("accepted");
      let apaformat = this.route.snapshot.queryParamMap.get("apaformat");
      if (showall == "true")
        this.showall = KeysPipe.showall = true;
      if (accepted == "true")
        this.accepted = true;
      if (apaformat == "true")
        this.apaformat = true;
    })
  }

  onLinkClick(event: MatTabChangeEvent) {
    if(event.tab.textLabel.includes("Print")) {
      this.print();
    }
  }

  print(): void {
    let printContents, popupWin;
    printContents = document.getElementById('print-section').innerHTML;
    popupWin = window.open('', '_blank', 'top=0,left=0,height=100%,width=auto');
    popupWin.document.open();
    let title = this.data.about.name;
    let html = `
      <html>
        <head>
          <title>Resume of ${title}</title>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/angular-material/1.1.10/angular-material.min.css">
          <style>
          ol {
            list-style-position: outside;
            padding-left:1.5em;
          }
          </style>
        </head>
    <body onload="window.print()">${printContents}</body>
      </html>`;
    console.log(html);
    popupWin.document.write(html);
    popupWin.document.close();
}

test() {
  window.alert("Hi");
}
}

