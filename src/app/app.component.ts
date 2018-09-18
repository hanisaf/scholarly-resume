import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { MatTabChangeEvent } from '@angular/material';
import {CoAuthorsPipe} from './pipes';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})

export class AppComponent  {
  data: any; 
  constructor(private http: HttpClient) {
    this.http.get("assets/data.json").subscribe( res => { console.log(res); this.data=res; CoAuthorsPipe.me = this.data.about.name; });
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
    popupWin.document.write(`
      <html>
        <head>
          <title>Resume of ${title}</title>
          <style>
          //........Customized style.......
          </style>
        </head>
    <body onload="window.print()">${printContents}</body>
      </html>`
    );
    popupWin.document.close();
}
}

