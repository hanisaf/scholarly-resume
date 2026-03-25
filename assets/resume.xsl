<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- ======================================================================
       Named template: tenure date range
       ====================================================================== -->
  <xsl:template name="tenure">
    <xsl:param name="startdate"/>
    <xsl:param name="enddate"/>
    <xsl:if test="$startdate and $startdate != ''">
      <xsl:value-of select="$startdate"/>
      <xsl:text>&#x2014;</xsl:text>
      <xsl:if test="$enddate and $enddate != ''">
        <xsl:value-of select="$enddate"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ======================================================================
       Named template: co-authors line  (show up to 10, then "and others")
       ====================================================================== -->
  <xsl:template name="coauthors">
    <xsl:param name="authors-node"/>
    <xsl:param name="me"/>
    <!-- collect non-self authors -->
    <xsl:variable name="others-count"
      select="count($authors-node/author[. != $me])"/>
    <xsl:if test="$others-count &gt; 0">
      <xsl:text> (joint work with </xsl:text>
      <xsl:for-each select="$authors-node/author[. != $me]">
        <xsl:if test="position() &lt;= 10">
          <xsl:if test="position() &gt; 1">
            <xsl:choose>
              <xsl:when test="position() = last() and $others-count &lt;= 10">
                <xsl:text> &amp; </xsl:text>
              </xsl:when>
              <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:value-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="$others-count &gt; 10">
        <xsl:text>, and others</xsl:text>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- ======================================================================
       Named template: a single card  (header + content slot)
       Content is passed via apply-templates on a node-set — callers wrap
       the content in a local template instead.
       ====================================================================== -->

  <!-- ======================================================================
       ROOT
       ====================================================================== -->
  <xsl:template match="/resume">
    <xsl:variable name="name" select="about/name"/>
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="$name"/></title>
        <style><![CDATA[
          /* ---- reset / base ---- */
          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            font-family: Roboto, "Helvetica Neue", Arial, sans-serif;
            font-size: 15px;
            background: #f2f2f2;
            color: #111;
            line-height: 1.55;
          }
          a { color: #ba0c2f; text-decoration: none; }
          a:hover { text-decoration: underline; }

          /* ---- top header bar ---- */
          .app-toolbar {
            background: #ba0c2f;
            color: #fff;
            padding: 0 24px;
            height: 64px;
            display: flex;
            align-items: center;
            font-size: 20px;
            font-weight: 500;
            box-shadow: 0 2px 4px rgba(0,0,0,.4);
            position: sticky;
            top: 0;
            z-index: 100;
          }

          /* ---- tab bar ---- */
          .tab-bar {
            background: #111;
            display: flex;
            overflow-x: auto;
            scrollbar-width: none;
          }
          .tab-bar::-webkit-scrollbar { display: none; }
          .tab-btn {
            background: none;
            border: none;
            color: rgba(255,255,255,.65);
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            letter-spacing: .04em;
            padding: 0 24px;
            height: 48px;
            white-space: nowrap;
            text-transform: uppercase;
            transition: color .2s, border-bottom .2s;
            border-bottom: 3px solid transparent;
            flex-shrink: 0;
          }
          .tab-btn:hover { color: #fff; background: rgba(255,255,255,.08); }
          .tab-btn.active {
            color: #fff;
            border-bottom: 3px solid #ba0c2f;
          }

          /* ---- tab content ---- */
          .tab-content { display: none; padding: 16px; max-width: 900px; margin: 0 auto; }
          .tab-content.active { display: block; }

          /* ---- card ---- */
          .card {
            background: #fff;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,.12);
            margin-bottom: 16px;
            overflow: hidden;
          }
          .card-header {
            padding: 16px 16px 8px;
            font-size: 16px;
            font-weight: 600;
            color: #ba0c2f;
            border-bottom: 2px solid #ba0c2f;
            text-transform: capitalize;
          }
          .card-content { padding: 8px 16px 16px; }

          /* ---- profile header card ---- */
          .profile-card { display: flex; align-items: flex-start; gap: 16px; }
          .profile-info { flex: 1; }
          .profile-name { font-size: 26px; font-weight: 700; line-height: 1.2; margin-bottom: 4px; color: #111; }
          .profile-subtitle { font-size: 15px; font-weight: 600; color: #555; }
          .profile-blurb { margin-top: 10px; color: #333; }

          /* ---- website buttons ---- */
          .website-links { display: flex; flex-wrap: wrap; gap: 8px; }
          .website-btn {
            display: inline-block;
            padding: 6px 14px;
            border: 1px solid #ba0c2f;
            border-radius: 4px;
            color: #ba0c2f;
            font-size: 13px;
            font-weight: 500;
            transition: background .15s, color .15s;
          }
          .website-btn:hover { background: #ba0c2f; color: #fff; text-decoration: none; }

          /* ---- list ---- */
          .item-list { list-style: none; }
          .item-list li {
            padding: 10px 0;
            border-bottom: 1px solid #eee;
            display: flex;
            gap: 12px;
          }
          .item-list li:last-child { border-bottom: none; }
          .tenure-col {
            white-space: nowrap;
            color: #555;
            min-width: 100px;
            font-size: 13px;
            padding-top: 1px;
          }
          .item-body { flex: 1; }
          .item-title { font-weight: 500; }
          .item-venue { color: #444; }
          .item-meta { font-size: 13px; color: #666; font-style: italic; }

          /* ---- nav list (linked items) ---- */
          .nav-list { list-style: none; }
          .nav-list li {
            padding: 10px 0;
            border-bottom: 1px solid #eee;
          }
          .nav-list li:last-child { border-bottom: none; }
          .nav-list a, .nav-list span.item-text {
            display: block;
            color: #111;
            font-size: 14px;
            line-height: 1.5;
            transition: color .15s;
          }
          .nav-list a:hover { color: #ba0c2f; text-decoration: none; }
          .nav-list .item-venue-year { color: #555; font-size: 13px; }
          .nav-list .item-coauthors { color: #666; font-size: 13px; font-style: italic; }

          /* ---- interests table ---- */
          .interests-table { width: 100%; border-collapse: collapse; }
          .interests-table th {
            text-align: left;
            font-weight: 600;
            color: #ba0c2f;
            padding: 6px 12px 6px 0;
            font-size: 14px;
            vertical-align: top;
          }
          .interests-table td {
            vertical-align: top;
            padding: 3px 12px 3px 0;
            font-size: 14px;
            color: #333;
          }

          /* ---- courses ---- */
          .course-chips { display: flex; flex-wrap: wrap; gap: 8px; }
          .course-chip {
            background: #fdeaea;
            border-radius: 16px;
            padding: 4px 12px;
            font-size: 13px;
            color: #ba0c2f;
          }

          /* ---- responsive ---- */
          @media (max-width: 768px) {
            .profile-name { font-size: 20px; }
            .tab-btn { padding: 0 14px; font-size: 12px; }
            .tab-content { padding: 10px; }
            .tenure-col { min-width: 80px; font-size: 12px; }
          }
          @media (max-width: 480px) {
            .app-toolbar { font-size: 16px; padding: 0 12px; }
            .profile-name { font-size: 17px; }
            .tab-btn { padding: 0 10px; }
            .item-list li { flex-direction: column; gap: 2px; }
            .tenure-col { min-width: unset; }
          }
        ]]></style>
      </head>
      <body>
        <div class="app-toolbar">
          <xsl:value-of select="about/name"/>
        </div>

        <!-- Tab navigation -->
        <div class="tab-bar" role="tablist">
          <button class="tab-btn active" onclick="showTab('about',this)" role="tab">About</button>
          <button class="tab-btn" onclick="showTab('research',this)" role="tab">Research</button>
          <button class="tab-btn" onclick="showTab('teaching',this)" role="tab">Teaching</button>
          <button class="tab-btn" onclick="showTab('service',this)" role="tab">Service</button>
          <button class="tab-btn" onclick="showTab('talks',this)" role="tab">Talks</button>
          <button class="tab-btn" onclick="showTab('recognition',this)" role="tab">Recognition</button>
        </div>

        <!-- Tab panes -->
        <div id="about" class="tab-content active" role="tabpanel">
          <xsl:apply-templates select="about"/>
        </div>
        <div id="research" class="tab-content" role="tabpanel">
          <xsl:apply-templates select="research"/>
        </div>
        <div id="teaching" class="tab-content" role="tabpanel">
          <xsl:apply-templates select="teaching"/>
        </div>
        <div id="service" class="tab-content" role="tabpanel">
          <xsl:apply-templates select="service"/>
        </div>
        <div id="talks" class="tab-content" role="tabpanel">
          <xsl:apply-templates select="invitations"/>
        </div>
        <div id="recognition" class="tab-content" role="tabpanel">
          <xsl:apply-templates select="recognition"/>
        </div>

        <script><![CDATA[
          function showTab(id, btn) {
            document.querySelectorAll('.tab-content').forEach(function(el) {
              el.classList.remove('active');
            });
            document.querySelectorAll('.tab-btn').forEach(function(el) {
              el.classList.remove('active');
            });
            document.getElementById(id).classList.add('active');
            btn.classList.add('active');
          }
          // Activate tab from URL hash
          window.addEventListener('DOMContentLoaded', function() {
            var hash = window.location.hash.replace('#','');
            if (hash) {
              var btn = document.querySelector('.tab-btn[onclick*="' + hash + '"]');
              if (btn) btn.click();
            }
          });
        ]]></script>
      </body>
    </html>
  </xsl:template>

  <!-- ======================================================================
       ABOUT
       ====================================================================== -->
  <xsl:template match="about">
    <xsl:variable name="name" select="name"/>
    <!-- Profile card -->
    <div class="card">
      <div class="card-content">
        <div class="profile-card">
          <div class="profile-info">
            <div class="profile-name"><xsl:value-of select="name"/></div>
            <xsl:if test="../../about/work/entry[1]">
              <div class="profile-subtitle">
                <xsl:value-of select="work/entry[1]/@title"/>,
                <xsl:value-of select="work/entry[1]/@venue"/>
              </div>
            </xsl:if>
            <xsl:if test="blurb and blurb != ''">
              <div class="profile-blurb"><xsl:value-of select="blurb"/></div>
            </xsl:if>
          </div>
        </div>
      </div>
    </div>

    <!-- Online Presence -->
    <xsl:if test="websites/website">
      <div class="card">
        <div class="card-header">Online Presence</div>
        <div class="card-content">
          <div class="website-links">
            <xsl:for-each select="websites/website">
              <a class="website-btn" href="{@url}" target="_blank" rel="noopener">
                <xsl:value-of select="@title"/>
              </a>
            </xsl:for-each>
          </div>
        </div>
      </div>
    </xsl:if>

    <!-- Research and Teaching Interests -->
    <xsl:if test="interests/category">
      <div class="card">
        <div class="card-header">Research and Teaching Interests</div>
        <div class="card-content">
          <table class="interests-table">
            <tr>
              <xsl:for-each select="interests/category">
                <th><xsl:value-of select="@name"/></th>
              </xsl:for-each>
            </tr>
            <!-- Emit rows up to the maximum number of items in any category -->
            <xsl:call-template name="interests-rows">
              <xsl:with-param name="categories" select="interests/category"/>
              <xsl:with-param name="index" select="1"/>
              <xsl:with-param name="max">
                <!-- find max count via a sorting trick in XSLT 1.0 -->
                <xsl:for-each select="interests/category">
                  <xsl:sort select="count(item)" data-type="number" order="descending"/>
                  <xsl:if test="position()=1"><xsl:value-of select="count(item)"/></xsl:if>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
          </table>
        </div>
      </div>
    </xsl:if>

    <!-- Education -->
    <xsl:if test="education/entry">
      <div class="card">
        <div class="card-header">Education</div>
        <div class="card-content">
          <ul class="item-list">
            <xsl:for-each select="education/entry">
              <li>
                <span class="tenure-col">
                  <xsl:call-template name="tenure">
                    <xsl:with-param name="startdate" select="@startdate"/>
                    <xsl:with-param name="enddate" select="@enddate"/>
                  </xsl:call-template>
                </span>
                <span class="item-body">
                  <span class="item-title"><xsl:value-of select="@title"/></span>,
                  <span class="item-venue"><xsl:value-of select="@venue"/></span>
                </span>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>

    <!-- Work Experience -->
    <xsl:if test="work/entry">
      <div class="card">
        <div class="card-header">Work Experience</div>
        <div class="card-content">
          <ul class="item-list">
            <xsl:for-each select="work/entry">
              <li>
                <span class="tenure-col">
                  <xsl:call-template name="tenure">
                    <xsl:with-param name="startdate" select="@startdate"/>
                    <xsl:with-param name="enddate" select="@enddate"/>
                  </xsl:call-template>
                </span>
                <span class="item-body">
                  <span class="item-title"><xsl:value-of select="@title"/></span>,
                  <span class="item-venue"><xsl:value-of select="@venue"/></span>
                  <xsl:if test="@abstract and @abstract != ''">
                    <div class="item-meta"><xsl:value-of select="@abstract"/></div>
                  </xsl:if>
                </span>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>

    <!-- Industry Expertise -->
    <xsl:if test="expertise/entry">
      <div class="card">
        <div class="card-header">Industry Expertise</div>
        <div class="card-content">
          <ul class="item-list">
            <xsl:for-each select="expertise/entry">
              <li>
                <span class="tenure-col">
                  <xsl:call-template name="tenure">
                    <xsl:with-param name="startdate" select="@startdate"/>
                    <xsl:with-param name="enddate" select="@enddate"/>
                  </xsl:call-template>
                </span>
                <span class="item-body">
                  <xsl:choose>
                    <xsl:when test="@url and @url != ''">
                      <a class="item-title" href="{@url}" target="_blank" rel="noopener">
                        <xsl:value-of select="@title"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="item-title"><xsl:value-of select="@title"/></span>
                    </xsl:otherwise>
                  </xsl:choose>
                  ,&#160;<span class="item-venue"><xsl:value-of select="@venue"/></span>
                </span>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Helper: emit interest table rows recursively up to $max -->
  <xsl:template name="interests-rows">
    <xsl:param name="categories"/>
    <xsl:param name="index"/>
    <xsl:param name="max"/>
    <xsl:if test="$index &lt;= $max">
      <tr>
        <xsl:for-each select="$categories">
          <td><xsl:value-of select="item[$index]"/></td>
        </xsl:for-each>
      </tr>
      <xsl:call-template name="interests-rows">
        <xsl:with-param name="categories" select="$categories"/>
        <xsl:with-param name="index" select="$index + 1"/>
        <xsl:with-param name="max" select="$max"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ======================================================================
       RESEARCH
       ====================================================================== -->
  <xsl:template match="research">
    <xsl:variable name="me" select="/resume/about/name"/>
    <xsl:for-each select="section[not(@hidden='true') and @name!='work-in-progress' and @name!='working papers']">
      <div class="card">
        <div class="card-header"><xsl:value-of select="@name"/></div>
        <div class="card-content">
          <ul class="nav-list">
            <xsl:for-each select="paper">
              <li>
                <xsl:choose>
                  <xsl:when test="@url and @url != ''">
                    <a href="{@url}" target="_blank" rel="noopener">
                      <xsl:if test="@abstract and @abstract != ''">
                        <xsl:attribute name="title"><xsl:value-of select="@abstract"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="item-text">
                      <xsl:if test="@abstract and @abstract != ''">
                        <xsl:attribute name="title"><xsl:value-of select="@abstract"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
                <div class="item-venue-year">
                  <xsl:value-of select="@venue"/>
                  <xsl:if test="@year and @year != ''">
                    <xsl:text>, </xsl:text><xsl:value-of select="@year"/>
                  </xsl:if>
                  <xsl:if test="@amount and @amount != ''">
                    <xsl:text> ($</xsl:text><xsl:value-of select="@amount"/><xsl:text>)</xsl:text>
                  </xsl:if>
                </div>
                <xsl:if test="authors/author">
                  <div class="item-coauthors">
                    <xsl:call-template name="coauthors">
                      <xsl:with-param name="authors-node" select="authors"/>
                      <xsl:with-param name="me" select="$me"/>
                    </xsl:call-template>
                  </div>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================
       TEACHING
       ====================================================================== -->
  <xsl:template match="teaching">
    <xsl:if test="courses/course">
      <div class="card">
        <div class="card-header">Courses</div>
        <div class="card-content">
          <ul class="nav-list">
            <xsl:for-each select="courses/course">
              <li>
                <xsl:choose>
                  <xsl:when test="@url and @url != ''">
                    <a href="{@url}" target="_blank" rel="noopener">
                      <xsl:if test="@abstract and @abstract != ''">
                        <xsl:attribute name="title"><xsl:value-of select="@abstract"/></xsl:attribute>
                      </xsl:if>
                      <xsl:if test="@id and @id != ''">
                        <xsl:value-of select="@id"/>:
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="item-text">
                      <xsl:if test="@id and @id != ''">
                        <xsl:value-of select="@id"/>:
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ======================================================================
       SERVICE
       ====================================================================== -->
  <xsl:template match="service">
    <xsl:for-each select="section[not(@hidden='true')]">
      <div class="card">
        <div class="card-header"><xsl:value-of select="@name"/></div>
        <div class="card-content">
          <ul class="item-list">
            <xsl:for-each select="entry">
              <li>
                <span class="tenure-col">
                  <xsl:call-template name="tenure">
                    <xsl:with-param name="startdate" select="@startdate"/>
                    <xsl:with-param name="enddate" select="@enddate"/>
                  </xsl:call-template>
                </span>
                <span class="item-body">
                  <xsl:value-of select="@role"/>
                  <xsl:if test="@venue and @venue != ''">
                    <xsl:text> at </xsl:text>
                    <xsl:value-of select="@venue"/>
                  </xsl:if>
                  <xsl:if test="@venueshort and @venueshort != ''">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@venueshort"/>
                    <xsl:text>)</xsl:text>
                  </xsl:if>
                </span>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================
       INVITATIONS (Talks)
       ====================================================================== -->
  <xsl:template match="invitations">
    <xsl:for-each select="section[not(@hidden='true')]">
      <div class="card">
        <div class="card-header"><xsl:value-of select="@name"/></div>
        <div class="card-content">
          <ul class="nav-list">
            <xsl:for-each select="entry">
              <li>
                <xsl:choose>
                  <xsl:when test="@url and @url != ''">
                    <a href="{@url}" target="_blank" rel="noopener">
                      <xsl:if test="@abstract and @abstract != ''">
                        <xsl:attribute name="title"><xsl:value-of select="@abstract"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="item-text"><xsl:value-of select="@title"/></span>
                  </xsl:otherwise>
                </xsl:choose>
                <div class="item-venue-year">
                  <xsl:value-of select="@venue"/>
                  <xsl:if test="@year and @year != ''">
                    <xsl:text>, </xsl:text><xsl:value-of select="@year"/>
                  </xsl:if>
                </div>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================
       RECOGNITION
       ====================================================================== -->
  <xsl:template match="recognition">
    <xsl:for-each select="section[not(@hidden='true')]">
      <div class="card">
        <div class="card-header"><xsl:value-of select="@name"/></div>
        <div class="card-content">
          <ul class="nav-list">
            <xsl:for-each select="entry">
              <li>
                <xsl:choose>
                  <xsl:when test="@url and @url != ''">
                    <a href="{@url}" target="_blank" rel="noopener">
                      <xsl:if test="@abstract and @abstract != ''">
                        <xsl:attribute name="title"><xsl:value-of select="@abstract"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="@title"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="item-text"><xsl:value-of select="@title"/></span>
                  </xsl:otherwise>
                </xsl:choose>
                <div class="item-venue-year">
                  <xsl:value-of select="@venue"/>
                  <xsl:if test="@year and @year != ''">
                    <xsl:text>, </xsl:text><xsl:value-of select="@year"/>
                  </xsl:if>
                </div>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
