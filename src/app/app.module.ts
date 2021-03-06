import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppComponent } from './app.component';
import {NoopAnimationsModule} from '@angular/platform-browser/animations';

import {ListFormat, LengthPipe, KeysPipe, CitesPipe, CoAuthorsPipe, MoneyPipe, TenurePipe, HighlightPipe, APAFormatPipe} from './pipes';

import {
  MatTabsModule,
  MatCardModule,
  MatListModule,
  MatButtonModule
} from '@angular/material';
import { RouterModule } from '@angular/router';


@NgModule({
  declarations: [
    AppComponent,
    KeysPipe,
    CitesPipe,
    MoneyPipe,
    CoAuthorsPipe,
    TenurePipe,
    HighlightPipe,
    LengthPipe,
    APAFormatPipe,
    ListFormat
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    NoopAnimationsModule,
    MatTabsModule, 
    MatCardModule,
    MatListModule,
    MatButtonModule,
    RouterModule.forRoot([])
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
