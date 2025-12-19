import { PipeTransform, Pipe } from '@angular/core';

@Pipe({
  name: 'length',
  standalone: true
})
export class LengthPipe implements PipeTransform {
  transform(value:Array<any> | null | undefined, range?: boolean): any {
    if(value) {
      if(range) {
        const rangeArray = Array(value.length);
        return rangeArray.fill(0).map((x,i)=>i);
      } else
        return value.length;
    }
    else return range ? [] : 0;
  }
} 
@Pipe({
  name: 'keys',
  standalone: true
})
export class KeysPipe implements PipeTransform {
  static showall = false;
  transform(value: any) : any {
    let showall = KeysPipe.showall;
    let keys = [];
    for (let key in value) {
      if(showall || key.charAt(0)!="-" ) {
        if(key.charAt(1) != "-") {
          keys.push({key: key.replace("-",""), value: value[key]});
        }
      }
    }
    return keys;
  }
} 

@Pipe({
  name: 'cites',
  standalone: true
})
export class CitesPipe implements PipeTransform {
  transform(value: any, args:string[]) : any {
    return `<a href="${value.url}">${value.url}</a>`;
  }
} 

@Pipe({
  name: 'money',
  standalone: true
})
export class MoneyPipe implements PipeTransform {
  transform(value:number) : string {
    if(value) {
      return "($"+value+")";
    } else {return "";}
    
  }
} 

@Pipe({
  name: 'tenure',
  standalone: true
})
export class TenurePipe implements PipeTransform {
  transform(dates:Array<string|number>) : string {
    if(dates.length == 2) {
      let startdate= dates[0]; 
      let enddate=dates[1];
      if(startdate && enddate) {
        //if(startdate != enddate)
          return startdate + "—" + enddate;
        //else return ""+startdate;
      } else {
        if(startdate)
          return ""+startdate + "—";
        else if(enddate)
          return ""+enddate;
        else return "";
      }
    }
    return "";
  }
} 

@Pipe({
  name: 'highlight',
  standalone: true
})
export class HighlightPipe implements PipeTransform {
  transform(items: any[], filterHighlighted = true): any {
    if(!items) return [];
    if(filterHighlighted) {
      return items.filter(item => item.highlight == "yes");
    } else {
      return items.filter(item => item.highlight != "yes");
    }
      
  }
}
@Pipe({
  name: 'listformat',
  standalone: true
})
export class ListFormat implements PipeTransform {
  transform(list: Array<string>): string {
    let res = "";
    for(let i = 0; i < list.length; i++) {
      res = res + list[i];
      if(i < list.length - 1) {
        res = res + ", ";
      }
    }
    return res;
  }
}
@Pipe({
  name: 'apaformat',
  standalone: true
})
export class APAFormatPipe implements PipeTransform {
  static me = "";
  format_author(author: string): string {
    let names = author.split(" ");

    let res = names[names.length-1] + " " + names[0].substring(0, 1) + ".";
    return res;
  }
  format_authors(authors: Array<string>): string {
    let res = "";
    for(let person of authors) {
      res = res + this.format_author(person) + ", ";
    }
    res = res.substring(0, res.length-2);
    res=res.replace(/,([^,]*)$/," &"+'$1');
    return res;
  }

  transform(paper: any) : string {
    let year = "";
    if ( ( "" + paper.year).indexOf("work") == -1) {
      year = " (" + paper.year + ")"
    }
    let venue = "";
    if (paper.venue != "TBD") {
      venue = " " + paper.venue + ".";
    }
    return this.format_authors(paper.authors) + year + ". " 
      + paper.title  + "." + venue;
  }
}

@Pipe({
  name: 'coauthors',
  standalone: true
})
export class CoAuthorsPipe implements PipeTransform {
  static me = "";
  transform(authors: Array<string>): string {
    if(authors) {
      let res = "(joint work with "
      let marker = false; //ensuring at least one author is added to the list
      let n = 0; //max of 10 authors
      for(let person of authors) {
        if(person != CoAuthorsPipe.me) {
          res = res + person + ", ";
          marker = true;
          n = n + 1;
          if(n >= 10) {
            res = res + "other authors  ";
            break;
          }
        }
      }
      res = res.substr(0, res.length-2);
      let i = res.lastIndexOf(",");
      res=res.replace(/,([^,]*)$/," &"+'$1'); 
      if(marker)
        return res + ")";
      else return "";
    }
    else {return ""};
  }
}