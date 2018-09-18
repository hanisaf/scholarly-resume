import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppComponent } from './app.component';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';

import {KeysPipe, CitesPipe, CoAuthorsPipe, MoneyPipe, TenurePipe, HighlightPipe} from './pipes';

import {
  MatTabsModule,
  MatCardModule,
  MatListModule
} from '@angular/material';


@NgModule({
  declarations: [
    AppComponent,
    KeysPipe,
    CitesPipe,
    MoneyPipe,
    CoAuthorsPipe,
    TenurePipe,
    HighlightPipe
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    BrowserAnimationsModule,
    MatTabsModule, 
    MatCardModule,
    MatListModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
