import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppComponent } from './app.component';
import {NoopAnimationsModule} from '@angular/platform-browser/animations';

import {LengthPipe, KeysPipe, CitesPipe, CoAuthorsPipe, MoneyPipe, TenurePipe, HighlightPipe} from './pipes';

import {
  MatTabsModule,
  MatCardModule,
  MatListModule,
  MatExpansionModule
} from '@angular/material';


@NgModule({
  declarations: [
    AppComponent,
    KeysPipe,
    CitesPipe,
    MoneyPipe,
    CoAuthorsPipe,
    TenurePipe,
    HighlightPipe,
    LengthPipe
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    NoopAnimationsModule,
    MatTabsModule, 
    MatCardModule,
    MatListModule,
    MatExpansionModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
