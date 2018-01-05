import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppComponent } from './app.component';
import {NoopAnimationsModule} from '@angular/platform-browser/animations';

import {KeysPipe, CitesPipe} from './pipes';

import {
  MatTabsModule,
  MatCardModule,
  MatListModule
} from '@angular/material';


@NgModule({
  declarations: [
    AppComponent,
    KeysPipe,
    CitesPipe
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    NoopAnimationsModule,
    MatTabsModule, 
    MatCardModule,
    MatListModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
