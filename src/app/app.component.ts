import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { NgModule }      from '@angular/core';
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})

export class AppComponent  {
  data: any; 
  constructor(private http: HttpClient) {
    this.http.get("assets/data.json").subscribe( res => this.data=res );
  }
 

}
