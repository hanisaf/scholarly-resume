import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { MatTabsModule, MatTabChangeEvent } from '@angular/material/tabs';
import { MatCardModule } from '@angular/material/card';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { ActivatedRoute, RouterModule } from "@angular/router";
import {
  APAFormatPipe,
  CoAuthorsPipe,
  KeysPipe,
  LengthPipe,
  TenurePipe,
  HighlightPipe,
  ListFormat
} from './pipes';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  standalone: true,
  imports: [
    CommonModule,
    MatTabsModule,
    MatCardModule,
    MatListModule,
    MatButtonModule,
    RouterModule,
    APAFormatPipe,
    CoAuthorsPipe,
    KeysPipe,
    LengthPipe,
    TenurePipe,
    HighlightPipe,
    ListFormat
  ]
})

export class AppComponent implements OnInit {
  data: any; 
  accepted = false;
  showall=false;
  apaformat=false;
  constructor(private http: HttpClient, private route: ActivatedRoute) {
    this.http.get("assets/data.json").subscribe( res => {  this.data=res; CoAuthorsPipe.me = this.data.about.name; });
  }

  ngOnInit(): void {
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

  onLinkClick(event: MatTabChangeEvent): void {
    if(event.tab.textLabel.includes("Print")) {
      this.print();
    }
  }

  print(): void {
    // Use setTimeout to ensure the DOM is updated after tab switch
    setTimeout(() => {
      let printContents, popupWin;
      const printSection = document.getElementById('print-section');
      if (!printSection) {
        console.error('Print section not found');
        return;
      }
      printContents = printSection.innerHTML;
      popupWin = window.open('', '_blank', 'top=0,left=0,height=100%,width=auto');
      if (!popupWin) {
        console.error('Failed to open print window. Please check your popup blocker settings.');
        return;
      }
      popupWin.document.open();
      let title = this.data.about.name;
      let html = `
        <html>
          <head>
            <title>Resume of ${title}</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/angular-material/1.1.10/angular-material.min.css">
            <style>
            body {
              font-family: "Times New Roman", Times, serif;
            }
            ol {
              list-style-position: outside;
              padding-left:1.5em;
            }
            </style>
          </head>
      <body onload="window.print();window.close()">${printContents}</body>
        </html>`;
      console.log(html);
      popupWin.document.write(html);
      popupWin.document.close();
    }, 100);
}

test() {
  window.alert("Hi");
}
}

