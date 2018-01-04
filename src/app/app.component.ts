import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  //title = 'app';
  data: any; 
  constructor(private http: HttpClient) {
    this.http.get("assets/data.json").subscribe( res => this.data=res );
  }
}
